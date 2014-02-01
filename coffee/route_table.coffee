class Routes.RouteTable

  constructor: (container) ->
    @container = container
    @route = []
    @_route_segment_line_string_cache = {}
    @initialize_svg()

  initialize_svg: ->
    @svg = d3.select('body').select('div#map').append('svg').attr('width', 1200).attr('height', 800)
    @current_route_group = @svg.append('g')
    @potential_route_group = @svg.append('g')
    console.log('initialize svg', @svg)

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
          route_segments.push(new Routes.RouteSegment(s))
          route_segments.push(new Routes.RouteSegment(s).reverse())

      @_route_segments = route_segments
      return @
    @_route_segments

  nest_by_id: (d) ->
    nest = {}
    (nest[object.id] = object) for object in d
    nest

  points_as_geojson: ->
    points = []
    for point in @route_points()
      do (point) ->
        if point.latitude and point.longitude
          points.push({
            type: "Feature"
            geometry: {
              type: "Point"
              coordinates: [parseFloat(point.longitude), parseFloat(point.latitude)]
            }
          })
    points

  render: ->
    @render_segments_table()
    @render_next_segments_to_map()
    # @render_points_to_map()
    #

  route_segment_line_string_cache: (id, callback = (-> null)) ->
    if a = @_route_segment_line_string_cache[id]
      callback(a)
    else
      rslsc = @_route_segment_line_string_cache
      store_and_execute_callback = (result) ->
        rslsc[id] = result
        callback(result)
      (new Routes.GPXParser).parse_gpx("data/gpx/#{id}.gpx", 'line_string', store_and_execute_callback)
    


  projection: (proj) ->
    if proj
      @_projection = proj
      return @
    @_projection


  render_path_to_map: (path_id, options = {}) ->
    projection = @projection()
    group = options.group or @current_route_group
    cache = @_route_segment_line_string_cache

    render_callback = (result) ->
      path = d3.geo.path().projection(projection)
      point = group.append('path').attr('id', "#route_path_#{path_id}").datum(result)
        .attr('d', path)
        .style('stroke', options.color or 'blue')
        .style('stroke-width', '1.5pt')
        .style('stroke-dasharray', options.stroke_dasharray or 'none')
        .style('fill', 'none')

    @route_segment_line_string_cache(path_id, render_callback)


  render_next_segments_to_map: ->
    @potential_route_group.selectAll('path').remove()
    for potential_route in @filtered_route_segments()
      do (potential_route) =>
        if potential_route.mappable()
          @render_path_to_map(potential_route.id, { color: 'red', group: @potential_route_group, stroke_dasharray: '3,3' })




  
  render_points_to_map: ->
    path = d3.geo.path().projection(@_context_map.projection()).pointRadius(4)
    console.log(@points)

    points = @_context_map.group.selectAll('.route_point').data(@points_as_geojson())
    points.enter()
      .append('path').attr('class', 'route_point')
      .attr('d', path)
      .style('fill', 'red')

  filtered_route_segments: =>
    if @route.length is 0
      (x for x in @route_segments() when x.start_point_id() is 2) # GGB
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
    controls.append('a').attr('href', '#')
      .on('click', (d) =>
        @add_to_route(d)
      ).text('add')
    rs.exit().remove()

  add_to_route: (d) ->
    for s in d.components()
      do (s) =>
        @route.push(s)
        @render_path_to_map(s.id)
    @render_route_table()
    @render_segments_table()
    @render_next_segments_to_map()

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
    [segment.id, @segment_name(segment), @miles(segment), @elevation(segment), @reverse_elevation(segment)]

  segment_name: (segment) ->
    segment.name() or @segment_name_from_points(segment)

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

  context_map: (json, dataset_name, options = {}) ->
    @_context_map = new Routes.ContextMap(@svg, json, dataset_name, options)




