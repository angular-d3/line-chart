angular.module('directives', [])

.factory('windowManager', function() {
  var groundValue = 100;
  var scopes = [];

  update = function() {
    scopes.forEach(function(item, index) {
      item.zIndexSetter(index + groundValue);
    });
  };

  getScopeIndex = function(scope) {
    var i = -1;
    scopes.forEach(function(item, index) {
      if (item.scope.$id === scope.$id) {
        i = index;
        return;
      }
    });

    return i;
  };

  return {
    open: function(scope, zIndexSetter) {
      scopes.push({scope: scope, zIndexSetter: zIndexSetter});
      update();
    },

    close: function(scope) {
      scopes.splice(getScopeIndex(scope), 1);
      update();
    },

    bringToFront: function(scope) {
      var item = scopes.splice(getScopeIndex(scope), 1);
      scopes.push(item[0]);
      update();
    }
  }
})

.directive('floatingWindow', ['windowManager', function(windowManager) {
  return {
    restrict: 'E',
    scope: {open: '='},
    link: function(scope, element, attrs) {
      scope.zIndex = 0;

      scope.setZIndex = function(value) {
        scope.zIndex = value;
      };

      scope.$watch('open', function(value) {
        if (!!value) {
          windowManager.open(scope, scope.setZIndex);
        } else {
          windowManager.close(scope, scope.setZIndex);
        }
      });

      scope.close = function() {
        scope.open = false;
      };

      scope.bringMeToFront = function() {
        windowManager.bringToFront(scope);
      }
    },
    transclude: true,
    replace: true,
    template: '<div ng-mousedown="bringMeToFront()" ng-style="{\'z-index\': zIndex}" ng-show="open" class="pure-u-1 floating">' +
    '<div drag-parent class="drag-handle">Drag me !<span class="close-handle icon" ng-click="close()"><i class="fa fa-times"></i></span></div>' +
    '<div class="scrollable" ng-transclude></div>' +
    '</div>'
  }
}])

.directive('dragParent', ['$document', function($document) {
  return function(scope, element, attr) {
    var startX = 0, startY = 0, x = 0, y = 0;

    var rect = element[0].parentNode.getBoundingClientRect()
    x = rect.left;
    y = rect.top;

    element.on('mousedown', function(event) {
      // Prevent default dragging of selected content
      event.preventDefault();
      startX = event.pageX - x;
      startY = event.pageY - y;

      $document.on('mousemove', mousemove);
      $document.on('mouseup', mouseup);
    });

    function mousemove(event) {
      y = event.pageY - startY;
      x = event.pageX - startX;
      angular.element(element[0].parentNode).css({
        top: y + 'px',
        left:  x + 'px'
      });
    }

    function mouseup() {
      $document.off('mousemove', mousemove);
      $document.off('mouseup', mouseup);
    }
  };
}])

.directive('chartOptionsEditor', function() {
  return {
    templateUrl: "templates/options.html",
    restrict: 'E',
    replace: true,
    scope: {options: '=', data: '='},
    link: function(scope, element, attrs) {
      scope.fields = []

      scope.$watch('data', function(v){
        if (!v) {
          return;
        }

        scope.fields = [];

        for (key in v[0]) {
          scope.fields.push(key);
        }
      });


      scope.interpolationModes = [
        "linear",
        "step-before",
        "step-after",
        "basis",
        "basis-open",
        "basis-closed",
        "bundle",
        "cardinal",
        "cardinal-open",
        "cadinal-closed",
        "monotone"
      ];

      scope.tooltipModes = ["none", "axes", "scrubber"];
      scope.fields = ["x", "val_0", "val_1", "val_2", "val_3"];

      scope.addSeries = function() {
        scope.options.series.unshift({y: scope.fields[scope.fields.length - 1]});
      };

      scope.addStack = function() {
        scope.options.stacks.unshift({axis: 'y', series: []});
      };

      scope.removeSeries = function(series) {
        scope.options.series.splice(scope.options.series.indexOf(series), 1);
      };

      scope.removeStack = function(stack) {
        scope.options.stacks.splice(scope.options.stacks.indexOf(stack), 1);
      };
    }
  }
})

.directive('series', function() {
  return {
    templateUrl: "templates/series.html",
    restrict: 'E',
    replace: true,
    scope: {series: '=', fields: '=', remove: '&'},
    link: function(scope, element, attrs) {
      scope.types = ["line", "area", "column"];
      scope.axes = ["y", "y2"];

      scope.thickness = 1

      scope.$watch('series', function(v) {
        if (!v || !v.thickness) {
          return;
        }

        scope.thickness = +v.thickness.replace('px', '');

        scope.isDashed = v.lineMode === 'dashed';

        if (scope.series.type !== 'column') {
          scope.series.drawDots = scope.series.drawDots !== false;
        }
      }, true);

      scope.$watch('thickness', function(v) {
        scope.series.thickness = v + 'px';
      });

      scope.$watch('isDashed', function(v) {
        scope.series.lineMode = v ? 'dashed' : undefined;
      });
    }
  }
})

.directive('stack', function($timeout) {
  return {
    templateUrl: "templates/stack.html",
    restrict: 'E',
    replace: true,
    scope: {series: '=allSeries', stacks: '=', stack: '=', remove: '&'},
    link: function(scope, element, attrs) {
      scope.axes = ["y", "y2"];

      scope.toggleSeries = function(series) {
        index = scope.stack.series.indexOf(series.id);

        if (index > -1) {
          scope.stack.series.splice(index, 1);
        } else {
          scope.stack.series.push(series.id);
        }
      };

      scope.getSeries = function(id) {
        return scope.series.filter(function(s) {return s.id === id;})[0];
      };

      scope.availableSeries = {y: [], y2: []};

      updateAvailableSeries = function() {
        scope.availableSeries.y = [];
        scope.availableSeries.y2 = [];

        stacks = scope.stacks;

        if (!stacks || !scope.series || scope.series.length === 0) {
          return;
        }

        scope.series.forEach(function(s) {
          s = angular.copy(s)

          s.disabled = false;

          if (scope.stack.series.indexOf(s.id) > -1) {
            s.selected = true;
          } else {
            s.selected = false;

            for (var i = 0; i < scope.stacks.length ; i++) {
              index = scope.stacks[i].series.indexOf(s.id);

              if (index > -1) {
                s.disabled = true;
                break;
              }
            }
          }

          scope.availableSeries[s.axis].push(s);

        });
      };

      scope.$watch('stacks', updateAvailableSeries, true);
      scope.$watch('series', updateAvailableSeries, true);
    }
  }
})

.directive('axis', function() {
  return {
    templateUrl: "templates/axis.html",
    restrict: 'E',
    replace: true,
    scope: {axis: '=', key: '=', fields: '='},
    link: function(scope, element, attrs) {
      scope.xTypes = ['linear', 'date'];
      scope.yTypes = ['linear', 'log'];
    }
  }
})