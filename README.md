# n3-charts.line-chart [![Build Status](https://drone.io/github.com/n3-charts/line-chart/status.png)](https://drone.io/github.com/n3-charts/line-chart/latest)

A line chart implementation for [AngularJS](http://angularjs.org/) applications. It makes an extensive use of the wonderful [D3.js](http://d3js.org/) library.

Here is a [demo page](http://n3-charts.github.io/line-chart/).

### How to install
 + Copy `line-chart.min.js` wherever you want
 + Reference it in your index.html file
 + Reference the module in your app file :
     angular.module('myApp', [
      'n3-charts.linechart'
    ])

### How to use
A line chart is called using this syntax :

```html
<linechart data="data" options="options" mode=""></linechart>
```

The line chart directives needs two attributes : `data` and `options`. If one is missing, nothing happens.

#### Data
Your data should look like this :

```js
$scope.data = [
  {x: 0, value: 4, otherValue: 14},
  {x: 1, value: 8, otherValue: 1},
  {x: 2, value: 15, otherValue: 11},
  {x: 3, value: 16, otherValue: 147},
  {x: 4, value: 23, otherValue: 87},
  {x: 5, value: 42, otherValue: 45}
];
```

#### Options
Options must be an object with a series array. It should look like this :

```js
$scope.options = {
  axes: {
    x: {key: 'x', labelFunction: function(value) {return value;}, type: 'linear', tooltipFormatter: function(x) {return x;}},
    y: {type: 'linear'},
    y2: {type: 'linear'}
  },
  series: [
    {y: 'value', color: 'steelblue', , thickness: '2px', type: 'area', striped: true, label: 'Pouet'},
    {y: 'otherValue', axis: 'y2', color: 'lightsteelblue'}
  ],
  lineMode: 'linear',
  tension: 0.7
}
```
##### Axes
The `axes` keys can be undefined. Otherwise, it can contain an `x̀` key with the following properties :

 + `key` : optional, defines where the chart will look for abscissas values in the data (default is 'x').
 + `tooltipFormatter` : optional, allows to format the tooltip. Must be a function that accepts a single argument, the x value. It should return something that will be converted into a string and put in the x tooltip.
 + `type` : optional, can be either 'date' or 'linear' (default is 'linear'). If set to 'date', the chart will expect Date objects as abscissas. No transformation is done by the chart itself, so the behavior is basically D3.js' time scale's.
 + `labelFunction` : optional, allows to format the axis' ticklabels. Must be a function that accepts a single argument and returns a string.

It can also contain, according to your series configuration, a `y` and a `y2` key with the following properties :

 + `type` : optional, can be either linear' or 'log' (default is 'linear'). If set to 'log', the data may be clamped if its computed lower bound is 0 (this means the chart won't display an actual 0, but a close value - log scales can't display zero values).


##### Series
The `series` key must be an array which contains objects with the following properties :

+ `y` : mandatory, defines which property on each data row will be used as ordinate value.
+ `color` : optional, any valid HTML color (if none given, the chart will set it for you).
+ `label` : optional, will be used in the legend (if undefined, the `y` value will be used).
+ `axis` : optional, can be either 'y' (default, for left) or 'y2' (for right). Defines which vertical axis should be used for this series. If no right axis is needed, none will be displayed.
+ `type` : optional, can be one value between 'line', 'area', 'column'. Default is 'line'.
+ `striped` : optional, can be either `true` or `false`. Default is `false`. Will be ignored if the series type is not 'area'.
+ `thickness` : optional, can be `{n}px`. Default is `1px`. Will be ignored if the series type is not 'area' or 'line'.

##### Optional stuff
Additionally, you can set `lineMode` to a value between these :

+ linear *(default)*
+ step-before
+ step-after
+ basis
+ basis-open
+ basis-closed
+ bundle
+ cardinal
+ cardinal-open
+ cadinal-closed
+ monotone

The `tension` can be set, too (default is `0.7`). See [issue #44][2] about that.

> For more information about interpolation, please consult the [D3.js documentation about that][1].

#### Mode
The mode can be set to 'thumbnail' (default is empty string). If so, the chart will take as much space as it can, and it will only display the series. No axes, no legend, no tooltips. Furthermore, the lines or areas will be drawn without dots. This is convenient for sparklines, for instance.

### Building
Fetch the repo :
```sh
$ git clone https://github.com/angular-d3/line-chart.git
```

Install stuff :
```sh
$ npm install
```

Install moar stuff :
```sh
$ bower install
```

Watch :
```sh
$ grunt watch
```

Hack.

### Testing
AngularJS is designed to be testable, and so is this project.
It has a good coverage rate (above 90%), and we want to keep it this way.

  [1]: https://github.com/mbostock/d3/wiki/SVG-Shapes#wiki-line_interpolate
  [2]: https://github.com/n3-charts/line-chart/issues/44
