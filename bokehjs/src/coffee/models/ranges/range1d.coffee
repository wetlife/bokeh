_ = require "underscore"

Range = require "./range"
p = require "../../core/properties"

class Range1d extends Range.Model
  type: 'Range1d'

  @define {
      start:  [ p.Number, 0 ]
      end:    [ p.Number, 1 ]
      bounds: [ p.Any       ] # TODO (bev)
      min_interval: [ p.Any ]
      max_interval: [ p.Any ]
    }

  _set_auto_bounds: () ->
    if @bounds == 'auto'
      min = Math.min(@_initial_start, @_initial_end)
      max = Math.max(@_initial_start, @_initial_end)
      @bounds = [min, max]

  constructor: () ->
    # new Range1d({start: start, end: end}) or Range1d(start, end)
    if this instanceof Range1d
      return super(arguments...)
    else
      [start, end] = arguments
      return new Range1d({start: start, end: end})

  initialize: (attrs, options) ->
    super(attrs, options)

    @_initial_start = @start
    @_initial_end = @end

    @_set_auto_bounds()

  @getters {
    min: () -> Math.min(@start, @end)
    max: () -> Math.max(@start, @end)
  }

  reset: () ->
    @setv({start: @_initial_start, end: @_initial_end})
    @_set_auto_bounds()

module.exports =
  Model: Range1d
