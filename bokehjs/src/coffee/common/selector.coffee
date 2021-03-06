_ = require "underscore"
HasProps = require "../core/has_props"
hittest = require "./hittest"
{logger} = require "../core/logging"
p = require "../core/properties"

class Selector extends HasProps
  type: 'Selector'

  update: (indices, final, append, silent=false) ->
    @setv('timestamp', new Date(), {silent: silent})
    @setv('final', final, {silent: silent})
    if append
      indices['0d'].indices =  _.union(@indices['0d'].indices, indices['0d'].indices)
      indices['0d'].glyph =  @indices['0d'].glyph or indices['0d'].glyph
      indices['1d'].indices =  _.union(@indices['1d'].indices, indices['1d'].indices)
      indices['2d'].indices =  _.union(@indices['2d'].indices, indices['2d'].indices)
    @setv('indices', indices, {silent: silent})

  clear: () ->
    @timestamp = new Date()
    @final = true
    @indices = hittest.create_hit_test_result()

  @internal {
    indices:   [ p.Any, () -> hittest.create_hit_test_result() ]
    final:     [ p.Boolean ]
    timestamp: [ p.Any ]
  }

module.exports = Selector
