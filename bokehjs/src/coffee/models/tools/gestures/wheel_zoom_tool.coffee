_ = require "underscore"

GestureTool = require "./gesture_tool"
p = require "../../../core/properties"

# Here for testing purposes
document = {} unless document?

class WheelZoomToolView extends GestureTool.View

  _pinch: (e) ->
    # TODO (bev) this can probably be done much better
    if e.scale >= 1
      delta = (e.scale - 1) * 20.0
    else
      delta = -20.0/e.scale
    e.bokeh.delta = delta
    @_scroll(e)

  _scroll: (e) ->
    frame = @plot_model.frame
    hr = frame.h_range
    vr = frame.v_range

    vx = @plot_view.canvas.sx_to_vx(e.bokeh.sx)
    vy = @plot_view.canvas.sy_to_vy(e.bokeh.sy)

    if vx < hr.start or vx > hr.end
      v_axis_only = true
    if vy < vr.start or vy > vr.end
      h_axis_only = true

    # we need a browser-specific multiplier to have similar experiences
    if navigator.userAgent.toLowerCase().indexOf("firefox") > -1
      multiplier = 20
    else
      multiplier = 1

    if e.originalEvent?.deltaY?
      delta = -e.originalEvent.deltaY * multiplier
    else
      delta = e.bokeh.delta

    factor  = @model.speed * delta

    # clamp the  magnitude of factor, if it is > 1 bad things happen
    if factor > 0.9
      factor = 0.9
    else if factor < -0.9
      factor = -0.9

    vx_low  = hr.start
    vx_high = hr.end

    vy_low  = vr.start
    vy_high = vr.end

    dims = @model.dimensions

    if dims.indexOf('width') > -1 and not v_axis_only
      sx0 = vx_low  - (vx_low  - vx)*factor
      sx1 = vx_high - (vx_high - vx)*factor
    else
      sx0 = vx_low
      sx1 = vx_high

    if dims.indexOf('height') > -1 and not h_axis_only
      sy0 = vy_low  - (vy_low  - vy)*factor
      sy1 = vy_high - (vy_high - vy)*factor
    else
      sy0 = vy_low
      sy1 = vy_high

    xrs = {}
    for name, mapper of frame.x_mappers
      [start, end] = mapper.v_map_from_target([sx0, sx1], true)
      xrs[name] = {start: start, end: end}

    yrs = {}
    for name, mapper of frame.y_mappers
      [start, end] = mapper.v_map_from_target([sy0, sy1], true)
      yrs[name] = {start: start, end: end}

    # OK this sucks we can't set factor independently in each direction. It is used
    # for GMap plots, and GMap plots always preserve aspect, so effective the value
    # of 'dimensions' is ignored.
    zoom_info = {
      xrs: xrs
      yrs: yrs
      factor: factor
    }
    @plot_view.push_state('wheel_zoom', {range: zoom_info})
    @plot_view.update_range(zoom_info, false, true)
    @plot_view.interactive_timestamp = Date.now()
    return null

class WheelZoomTool extends GestureTool.Model
  default_view: WheelZoomToolView
  type: "WheelZoomTool"
  tool_name: "Wheel Zoom"
  icon: "bk-tool-icon-wheel-zoom"
  event_type: if ('ontouchstart' of window or navigator.maxTouchPoints > 0) then 'pinch' else 'scroll'
  default_order: 10

  @getters {
    tooltip: () -> @_get_dim_tooltip(@tool_name, @_check_dims(@dimensions, "wheel zoom tool"))
  }

  @define {
    dimensions: [ p.Array, ["width", "height"] ]
  }

  @internal {
    speed: [ p.Number, 1/600 ]
  }

module.exports =
  Model: WheelZoomTool
  View: WheelZoomToolView
