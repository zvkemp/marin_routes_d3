window.Routes = {}

class AbstractRouteTable
  constructor: (data) ->
    @_data = data

  data: (d) ->
    if d
      @_data = d
      return @
    @_data

class RouteSegment
  constructor: (json) ->
    @id = json.id
    @_reversed = false
    @_miles = json.miles
    @_elevation = json.elevation
    @_reverse_elevation = json.reverse_elevation
    @_start_point_id = json.start_point_id
    @_end_point_id = json.end_point_id

  miles: -> @_miles

  elevation: ->
    if @_reversed then @_reverse_elevation else @_elevation

  reverse_elevation: ->
    if @_reversed then @_elevation else @_reverse_elevation

  start_point_id: ->
    if @_reversed then @_end_point_id else @_start_point_id

  end_point_id: ->
    if @_reversed then @_start_point_id else @_end_point_id

  reverse: ->
    @_reversed = (not @_reversed)
    @


class RouteTable extends AbstractRouteTable

  constructor: (container) ->
    @container = container
    @route = []

  route_points: (d) ->
    if d
      @_route_points = d
      @_route_points_by_id = @nest_by_id(d)
      return @
    @_route_points

  route_segments: (d) ->
    if d
      route_segments = []
      for s in d
        do (s) ->
          route_segments.push(new RouteSegment(s))
          route_segments.push(new RouteSegment(s).reverse())

      @_route_segments = route_segments
      return @
    @_route_segments

  nest_by_id: (d) ->
    nest = {}
    (nest[object.id] = object) for object in d
    nest


  render: ->
    @render_points_table()
    @render_segments_table()

  filtered_route_segments: =>
    if @route.length is 0
      @route_segments()
    else
      last_segment = @route[@route.length-1]
      end = (last_segment.end_point_id())
      (x for x in @route_segments() when x.start_point_id() is end)

  render_segments_table: ->
    segments_table = d3.select(@container).select('#segments')
    rs = segments_table.selectAll('tr.segment').data(@filtered_route_segments())
    rs.enter()
      .append('tr')
      .attr('class', 'segment')
    
    tds = rs.selectAll('td').data(@segment_as_array)
    tds.enter().append('td')
    tds.text((d) -> d)
    rs.selectAll('td.controls').remove()
    controls = rs.append('td').attr('class', 'controls')
    # controls.append('a').attr('href', '#')
    # .on('click', (d) =>
    # console.log('hello', d)
    # d.reverse()
    # @render_segments_table()
    # ).text('reverse')
    controls.append('a').attr('href', '#')
      .on('click', (d) =>
        console.log('adding...', d)
        @route.push(d)
        @render_route_table()
        @render_segments_table()
      ).text('add')
    rs.exit().remove()

  render_route_table: ->
    route_table = d3.select(@container).select('#route')
    rt = route_table.selectAll('tr.segment').data(@route)
    total = route_table.selectAll('tr.total').remove()
    rt.enter()
      .append('tr')
      .attr('class', 'segment')

    tds = rt.selectAll('td').data(@segment_as_array)
    tds.enter().append('td')
    tds.text((d) -> d)

    total = route_table.append('tr').attr('class', 'total')
    total.append('td')
    total.append('td').text('total:')
    summary = @route_summary()
    total.append('td').text(summary.miles)
    total.append('td').text(summary.elevation)

    rt.exit().remove()

  segment_as_array: (segment) =>
    [segment.id, @segment_name_from_points(segment), @miles(segment), @elevation(segment), @reverse_elevation(segment)]

  render_points_table: ->
    points_table = d3.select(@container).select('#points')
    rp = points_table.selectAll('tr.point').data(@route_points())
    rp.enter()
      .append('tr')
      .attr('class', 'point')
    rp.append('td').text((d) -> d.id)
    rp.append('td').text((d) -> d.name)

    rp.exit().remove()

  segment_name_from_points: (segment) =>
    s = segment.start_point_id()
    e = segment.end_point_id()
    r = @_route_points_by_id

    "#{s}-[#{r[s].name}] to #{e}-[#{r[e].name}]"

  miles: (segment) ->
    "#{segment.miles()} mi"

  elevation: (segment) ->
    "#{segment.elevation()} ft"

  reverse_elevation: (segment) ->
    "(#{segment.reverse_elevation()} ft)"

  route_summary: ->
    miles = 0
    elevation = 0
    for segment in @route
      do (segment) ->
        miles += segment.miles()
        elevation += segment.elevation()

    { miles: miles.toFixed(1), elevation: elevation }




runTables = ->
  window.table = new RouteTable('#container')

  d3.json("../data/route_points.json", (error, route_points) ->
    d3.json("../data/route_segments.json", (error, route_segments) ->
      table.route_points(route_points)
        .route_segments(route_segments)

      table.render()
    )
  )


runTables()

