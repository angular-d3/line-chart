describe 'event handling', ->
  beforeEach module 'n3-line-chart'
  beforeEach module 'testUtils'

  describe 'utils', ->
    n3utils = undefined

    beforeEach inject (_n3utils_) ->
      n3utils = _n3utils_

    it 'should create a dispatcher with event attrs', ->

      dispatch = n3utils.getEventDispatcher()

      expect(dispatch).to.have.property("focus")
      expect(dispatch).to.have.property("hover")
      expect(dispatch).to.have.property("click")
      expect(dispatch).to.have.property("toggle")
      expect(dispatch).to.have.property("mouseenter")
      expect(dispatch).to.have.property("mouseover")
      expect(dispatch).to.have.property("mouseout")

  describe 'rendering', ->
    element = undefined
    innerScope = undefined
    outerScope = undefined

    fakeMouse = undefined

    flushD3 = undefined

    beforeEach inject (n3utils, _fakeMouse_) ->
      flushD3 = ->
        now = Date.now
        Date.now = -> Infinity
        d3.timer.flush()
        Date.now = now

      fakeMouse = _fakeMouse_

      sinon.stub n3utils, 'getDefaultMargins', ->
        top: 20
        right: 50
        bottom: 30
        left: 50

      sinon.stub n3utils, 'getTextBBox', -> {width: 30}


    beforeEach inject (pepito) ->
      {element, innerScope, outerScope} = pepito.directive """
      <div>
        <linechart
          data='data'
          options='options'
          on-click='clicked'
          on-hover='hovered'
          on-focus='focused'
          on-toggle='toggled'
          on-mouseenter='mouseentered'
          on-mouseover='mouseovered'
          on-mouseout='mouseouted'
        ></linechart>
      </div>
      """

    beforeEach ->
      outerScope.$apply ->
        outerScope.data = [
          {x: 0, value: 4}
          {x: 1, value: 8}
          {x: 2, value: 15}
          {x: 3, value: 16}
          {x: 4, value: 23}
          {x: 5, value: 42}
        ]
        outerScope.options =
          series: [
            {
              y: 'value'
              color: '#4682b4'
            }
            {
              y: 'x'
              axis: 'y2'
              type: 'column'
              color: '#4682b4'
            }
          ]
          tooltip: {mode: 'axes', interpolate: false}

      sinon.stub(d3, 'mouse', -> [0, 0])

    afterEach ->
      d3.mouse.restore()

    it 'should dispatch a click event when clicked on a dot', ->

      clicked = undefined

      outerScope.$apply ->
        outerScope.options =
          series: [
            {y: 'value', color: '#4682b4'}
            {y: 'value', axis: 'y2', type: 'column', color: '#4682b4'}
          ]
          tooltip: {mode: 'axes'}
        outerScope.clicked = (d, i) ->
          clicked = [d, i]

      dotGroup = element.childByClass('dotGroup')

      dotGroup.children()[0].click()
      expect(clicked[0].x).to.equal(0)
      expect(clicked[0].y).to.equal(4)
      expect(clicked[1]).to.equal(0)

      dotGroup.children()[1].click()
      expect(clicked[0].x).to.equal(1)
      expect(clicked[0].y).to.equal(8)
      expect(clicked[1]).to.equal(1)

    it 'should dispatch a click event when clicked on a column', ->

      clicked = undefined

      outerScope.$apply ->
        outerScope.options =
          series: [
            {y: 'value', color: '#4682b4'}
            {y: 'value', axis: 'y2', type: 'column', color: '#4682b4'}
          ]
          tooltip: {mode: 'axes'}
        outerScope.clicked = (d, i) ->
          clicked = [d, i]

      columnGroup = element.childByClass('columnGroup')

      columnGroup.children()[0].click()
      expect(clicked[0].x).to.equal(0)
      expect(clicked[0].y).to.equal(4)
      expect(clicked[1]).to.equal(0)

      columnGroup.children()[1].click()
      expect(clicked[0].x).to.equal(1)
      expect(clicked[0].y).to.equal(8)
      expect(clicked[1]).to.equal(1)

    it 'should dispatch a hover event when hovering over a dot', ->

      hovered = undefined

      outerScope.$apply ->
        outerScope.options =
          series: [
            {y: 'value', color: '#4682b4'}
            {y: 'value', axis: 'y2', type: 'column', color: '#4682b4'}
          ]
          tooltip: {mode: 'axes'}
        outerScope.hovered = (d, i) ->
          hovered = [d, i]

      dotGroup = element.childByClass('dotGroup')

      fakeMouse.hoverIn(dotGroup.children()[0].domElement)
      expect(hovered[0].x).to.equal(0)
      expect(hovered[0].y).to.equal(4)
      expect(hovered[1]).to.equal(0)

      fakeMouse.hoverIn(dotGroup.children()[1].domElement)
      expect(hovered[0].x).to.equal(1)
      expect(hovered[0].y).to.equal(8)
      expect(hovered[1]).to.equal(1)

    it 'should dispatch a hover event when hovering over a column', ->

      hovered = undefined

      outerScope.$apply ->
        outerScope.options =
          series: [
            {y: 'value', color: '#4682b4'}
            {y: 'value', axis: 'y2', type: 'column', color: '#4682b4'}
          ]
          tooltip: {mode: 'axes'}
        outerScope.hovered = (d, i) ->
          hovered = [d, i]

      columnGroup = element.childByClass('columnGroup')

      fakeMouse.hoverIn(columnGroup.children()[0].domElement)
      expect(hovered[0].x).to.equal(0)
      expect(hovered[0].y).to.equal(4)
      expect(hovered[1]).to.equal(0)

      fakeMouse.hoverIn(columnGroup.children()[1].domElement)
      expect(hovered[0].x).to.equal(1)
      expect(hovered[0].y).to.equal(8)
      expect(hovered[1]).to.equal(1)

    it 'should dispatch a focus event when scrubber is displayed', ->

      focused = []

      outerScope.$apply ->
        outerScope.options =
          series: [
            {y: 'value', color: '#4682b4'}
            {y: 'value', axis: 'y2', type: 'column', color: '#4682b4'}
          ]
          tooltip: {mode: 'scrubber'}
        outerScope.focused = (d, i) ->
          focused.push([d, i])

      glass = element.childByClass('glass')

      fakeMouse.hoverIn(glass)
      fakeMouse.mouseMove(glass)
      flushD3()

      expect(focused[0][0].x).to.equal(focused[1][0].x)
      expect(focused[0][1]).to.equal(focused[0][1])

    it 'should dispatch a toggle event when clicked on a legend', ->

      clicked = undefined

      outerScope.$apply ->
        outerScope.options =
          series: [
            {y: 'value', color: '#4682b4'}
            {y: 'value', axis: 'y2', type: 'column', color: '#4682b4', visible: false}
          ]
          tooltip: {mode: 'axes'}
        outerScope.toggled = (d, i, visibility) ->
          clicked = [d, i, visibility]

      firstLegendItem = element.childrenByClass('legendItem')[0]
      secondLegendItem = element.childrenByClass('legendItem')[1]

      firstLegendItem.click()
      expect(clicked[1]).to.equal(0)
      expect(clicked[2]).to.equal(false)

      firstLegendItem.click()
      expect(clicked[1]).to.equal(0)
      expect(clicked[2]).to.equal(true)

      secondLegendItem.click()
      expect(clicked[1]).to.equal(1)
      expect(clicked[2]).to.equal(true)

    it 'should handle x zoom events', ->

      outerScope.$apply ->
        outerScope.options =
          margin:
            {left: 0, bottom: 0, top: 0, right: 0}
          axes:
            x: {zoomable: true}
          series: [
            {y: 'value', type: 'column'}
          ]

      columnGroup = element.childByClass('columnGroup')
      expect(columnGroup.children()[0].getAttribute('x')).to.equal('129')
      expect(columnGroup.children()[0].getAttribute('y')).to.equal('456')
      expect(columnGroup.children()[0].getAttribute('width')).to.equal('123')
      expect(columnGroup.children()[0].getAttribute('height')).to.equal('44')

      glass = element.childByClass('glass').domElement
      fakeMouse.wheel(glass, 0, -10)

      columnGroup = element.childByClass('columnGroup')
      expect(columnGroup.children()[0].getAttribute('x')).to.equal('130')
      expect(columnGroup.children()[0].getAttribute('y')).to.equal('456')
      expect(columnGroup.children()[0].getAttribute('width')).to.equal('125')
      expect(columnGroup.children()[0].getAttribute('height')).to.equal('44')

    it 'should handle x and y zoom events', ->

      outerScope.$apply ->
        outerScope.options =
          margin:
            {left: 0, bottom: 0, top: 0, right: 0}
          axes:
            x: {zoomable: true}
            y: {zoomable: true}
          series: [
            {y: 'value', type: 'column'}
          ]

      columnGroup = element.childByClass('columnGroup')
      expect(columnGroup.children()[0].getAttribute('x')).to.equal('129')
      expect(columnGroup.children()[0].getAttribute('y')).to.equal('456')
      expect(columnGroup.children()[0].getAttribute('width')).to.equal('123')
      expect(columnGroup.children()[0].getAttribute('height')).to.equal('44')

      glass = element.childByClass('glass').domElement
      fakeMouse.wheel(glass, 0, -10)

      columnGroup = element.childByClass('columnGroup')
      expect(columnGroup.children()[0].getAttribute('x')).to.equal('130')
      expect(columnGroup.children()[0].getAttribute('y')).to.equal('462')
      expect(columnGroup.children()[0].getAttribute('width')).to.equal('125')
      expect(columnGroup.children()[0].getAttribute('height')).to.equal('38')

    it 'should ignore zoom events by default', ->

      getColumn = -> element.childByClass('columnGroup').children()[0]

      outerScope.$apply ->
        outerScope.options =
          margin:
            {left: 0, bottom: 0, top: 0, right: 0}
          axes:
            x: {zoomable: false}
            y: {zoomable: false}
          series: [
            {y: 'value', type: 'column'}
          ]

      originalPosition =
        x: getColumn().getAttribute('x')
        y: getColumn().getAttribute('y')

      glass = element.childByClass('glass').domElement
      fakeMouse.wheel(glass, 0, -10)

      expect(getColumn().getAttribute('x')).to.equal(originalPosition.x)
      expect(getColumn().getAttribute('y')).to.equal(originalPosition.y)

    it 'should dispatch a mouseenter, mouseover and mouseout events when hovering over a dot', ->

      mouseenter = undefined
      mouseover = undefined
      mouseout = undefined

      outerScope.$apply ->
        outerScope.options =
          series: [
            {y: 'value', color: '#4682b4'}
            {y: 'value', axis: 'y2', type: 'column', color: '#4682b4'}
          ]
          tooltip: {mode: 'axes'}
        outerScope.mouseentered = (d, i) -> mouseenter = [d, i]
        outerScope.mouseovered = (d, i) -> mouseover = [d, i]
        outerScope.mouseouted = (d, i) -> mouseout = [d, i]

      dotGroup = element.childByClass('dotGroup')

      fakeMouse.mouseEnter(dotGroup.children()[0].domElement)
      expect(mouseenter[0].x).to.equal(0)
      expect(mouseenter[0].y).to.equal(4)
      expect(mouseenter[1]).to.equal(0)

      expect(mouseover).to.equal(undefined)
      expect(mouseout).to.equal(undefined)

      fakeMouse.mouseOver(dotGroup.children()[0].domElement)
      expect(mouseover[0].x).to.equal(0)
      expect(mouseover[0].y).to.equal(4)
      expect(mouseover[1]).to.equal(0)

      expect(mouseout).to.equal(undefined)

      fakeMouse.mouseOut(dotGroup.children()[0].domElement)
      expect(mouseout[0].x).to.equal(0)
      expect(mouseout[0].y).to.equal(4)
      expect(mouseout[1]).to.equal(0)
