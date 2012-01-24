{EventEmitter} = require 'events'

rand = -> (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

class Cycler extends EventEmitter
  constructor: ({@source, @prefix}) ->
    @source ?= ['localhost']
    @range = 8 - @prefix.split(':').length if @prefix?
    
  # TODO: Support for ipv4 ranges
  getIP: ->
    if @prefix?
      out = @prefix
      for num in @range
        out += ":#{rand()}"
      return out
    else # No prefix, select random from list
      @source[Math.floor(Math.random()*@source.length)]
      
module.exports = Cycler
