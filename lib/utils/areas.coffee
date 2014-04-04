      addPattern: (svg, series) ->
        group = svg.select('defs').append('pattern').attr(
          id: series.type + 'Pattern_' + series.index
          patternUnits: "userSpaceOnUse"
          x: 0
          y: 0
          width: 60
          height: 60
        ).append('g')
          .style(
            'fill': series.color
            'fill-opacity': 0.3
          )

        group.append('rect')
          .style('fill-opacity', 0.3)
          .attr('width', 60)
          .attr('height', 60)

        group.append('path')
          .attr('d', "M 10 0 l10 0 l -20 20 l 0 -10 z")

        group.append('path')
          .attr('d', "M40 0 l10 0 l-50 50 l0 -10 z")

        group.append('path')
          .attr('d', "M60 10 l0 10 l-40 40 l-10 0 z")

        group.append('path')
          .attr('d', "M60 40 l0 10 l-10 10 l -10 0 z")

      drawArea: (svg, scales, data, options) ->
        areaSeries = data.filter (series) -> series.type is 'area'

        areaSeries.forEach( ((series) -> this.addPattern(svg, series)), this )

        drawers =
          y: this.createLeftAreaDrawer(scales, options.lineMode, options.tension)
          y2: this.createRightAreaDrawer(scales, options.lineMode, options.tension)

        svg.select('.content').selectAll('.areaGroup')
          .data(areaSeries)
          .enter().append('g')
            .attr('class', (s) -> 'areaGroup ' + 'series_' + s.index)
            .append('path')
              .attr('class', 'area')
              .style('fill', (s) ->
                return s.color if s.striped isnt true
                return "url(#areaPattern_#{s.index})"
              )
              .style('opacity', (s) -> if s.striped then '1' else '0.3')
              .attr('d', (d) -> drawers[d.axis](d.values))

        return this

      createLeftAreaDrawer: (scales, mode, tension) ->
        return d3.svg.area()
          .x (d) -> return scales.xScale(d.x)
          .y0 (d) -> return scales.yScale(0)
          .y1 (d) -> return scales.yScale(d.value)
          .interpolate(mode)
          .tension(tension)

      createRightAreaDrawer: (scales, mode, tension) ->
        return d3.svg.area()
          .x (d) -> return scales.xScale(d.x)
          .y0 (d) -> return scales.y2Scale(0)
          .y1 (d) -> return scales.y2Scale(d.value)
          .interpolate(mode)
          .tension(tension)
