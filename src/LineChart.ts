module n3Charts {
  'use strict';

  interface ILineChartScope extends ng.IScope {
    data;
    datasets;
    options;
    styles;
  }

  export class LineChart implements ng.IDirective  {

    public scope = {
      data: '=',
      datasets: '=',
      options: '=',
      styles: '='
    };

    public restrict = 'E';
    public replace = true;
    public template = '<div></div>';

    link = (scope: ILineChartScope, element: JQuery, attributes: ng.IAttributes) => {
      var eventMgr = new Utils.EventManager();
      var factoryMgr = new Utils.FactoryManager();

      // Initialize global events
      eventMgr.init(Utils.EventManager.EVENTS);

      // Register all factories
      // Note: we can apply additional arguments to each factory
      factoryMgr.registerMany([
        ['container', Factory.Container, element[0]],
        ['transitions', Factory.Transition],
        ['x-axis', Factory.Axis, Factory.Axis.SIDE_X],
        ['y-axis', Factory.Axis, Factory.Axis.SIDE_Y],
        ['series-area', Factory.Series.Area],
        ['series-line', Factory.Series.Line],
        ['series-dot', Factory.Series.Dot],
        ['style', Factory.StyleSheet],
      ]);

      // Initialize all factories
      factoryMgr.all().forEach((f) => f.instance.init(f.key, eventMgr, factoryMgr));

      // Trigger the create event
      eventMgr.trigger('create');

      // Trigger the update event
      scope.$watchCollection('[options, datasets]', () => {
        // Call the update event with a copy of the options
        // and datasets to avoid infinite digest loop
        var options = new Utils.Options(angular.copy(scope.options));
        var datasets = new Utils.Datasets(angular.copy(scope.datasets));

        eventMgr.trigger('update', datasets, options);

        return;
      });

      // Trigger the destroy event
      scope.$on('$destroy', () => eventMgr.trigger('destroy'));
    };
  }
}
