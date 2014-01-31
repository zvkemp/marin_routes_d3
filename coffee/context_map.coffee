class Routes.ContextMap
  constructor: (json, dataset_name, options = {}) ->
    @_json = json
    @_dataset_name = dataset_name
    @_options = options
    @svg = d3.select('#map').append('svg')

  render: ->
    d3.json(@_json, (error, zips) =>
      console.log(zips)
      calizips = topojson.feature(zips, zips.objects[@_dataset_name]).features
      path = d3.geo.path().projection(@projection())

      map = @svg.append('g').attr('class', 'map')
      map.selectAll('.zip')
        .data(calizips)
        .enter()
        .append('path')
        .attr('class', 'zip')
        .attr('d', path)
        .style('fill', 'none')
        .style('stroke', 'black')
        .style('stroke-width', '0.1pt')
    )

  projection: (projection) ->
    if projection
      @_projection = projection
      return @
    @_projection
