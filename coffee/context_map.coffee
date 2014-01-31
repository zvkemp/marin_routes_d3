class Routes.ContextMap
  constructor: (container, json, dataset_name, options = {}) ->
    @_json = json
    @_dataset_name = dataset_name
    @_options = options
    @group = container.append('g')
    console.log(container, @group)

  render: ->
    d3.json(@_json, (error, json) =>
      calijson = topojson.feature(json, json.objects[@_dataset_name]).features
      path = d3.geo.path().projection(@projection())

      map = @group.append('g').attr('class', 'map')
      map.selectAll('.zip')
        .data(calijson)
        .enter()
        .append('path')
        .attr('class', 'zip')
        .attr('d', path)
        .style('fill', 'none')
        .style('stroke', @_options.stroke or 'black')
        .style('stroke-width', '0.1pt')
    )

  projection: (projection) ->
    if projection
      @_projection = projection
      return @
    @_projection
