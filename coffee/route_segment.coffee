class Routes.RouteSegment
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

  components: -> [@]

  name: -> null
