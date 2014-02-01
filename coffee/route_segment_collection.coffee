class Routes.RouteSegmentCollection
  constructor: (route_segments) ->
    @_segments = route_segments

  sum: (f) ->
    s = 0
    s += (f(x) or 0) for x in @_segments
    s
  
  miles: -> @sum((x) -> x.miles())

  elevation: ->
    @sum((x) -> x.elevation())

  reverse_elevation: ->
    @sum((x) -> x.reverse_elevation())

  start_point_id: ->
    @_segments[0].start_point_id()

  end_point_id: ->
    @_segments[@_segments.length - 1].end_point_id()

  reverse: ->
    return @ # do not reverse

  components: -> @_segments

  name: (n) ->
    if n
      @_name = n
      return @
    "<#{@_name}>" if @_name

  mappable: -> false
