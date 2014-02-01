runTables = ->
  window.table = new Routes.RouteTable('#container')

  d3.json("../data/route_points.json", (error, route_points) ->
    d3.json("../data/route_segments.json", (error, route_segments) ->
      table.route_points(route_points)
        .route_segments(route_segments)

      sycamore_to_east_peak_segment_ids = [1, 2, 4, 5, 6]
      segments = ((new Routes.RouteSegment(route_segments[id - 1])) for id in sycamore_to_east_peak_segment_ids)
      window.rsc = new Routes.RouteSegmentCollection(segments)
      rsc.name("Mt Tam from Mill Valley")
      table._route_segments.push(rsc)

      width = 1200
      height = 800

      projection = d3.geo.albers()
        .scale(123000)
        .rotate([122.4350, 0, 0])
        .center([0, 37.9800])
        .parallels([35,36])
        .translate([width/2, height/2])

      table.projection(projection)

      # table.context_map('data/sf_marin_roads.json', 'marin_roads', { stroke: 'red' })
      #   .projection(projection)
      #   .render()


      cm = table.context_map('data/bayarea.json', 'ba')
      cm.projection(projection).render()

      table.render()
    )
  )


runTables()

