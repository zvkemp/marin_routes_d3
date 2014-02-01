class Routes.GPXParser
  no_op: -> null

  parse_gpx: (datafile, feature_function, callback = @no_op) ->
    console.log 'parsing new gpx file'
    d3.xml datafile, 'application/xml', (gpx) =>
      result = @[feature_function](gpx)
      console.log(result)
      callback(result)

  points: (gpx) ->
    points_array = []
    for points in gpx.getElementsByTagName('trk')
      do (points) =>
        for point in points.getElementsByTagName('trkpt')
          do (point) =>
            points_array.push({
              type: "Feature"
              geometry: {
                type: "Point"
                coordinates: [ parseFloat(point.getAttribute('lon')), parseFloat(point.getAttribute('lat'))]
              }
            })
    points_array

  line_string: (gpx) ->
    coordinates = []
    for points in gpx.getElementsByTagName('trk')
      do (points) =>
        for point in points.getElementsByTagName('trkpt')
          do (point) =>
            coordinates.push([parseFloat(point.getAttribute('lon')), parseFloat(point.getAttribute('lat'))])

    { type: "LineString", coordinates: coordinates }


  
