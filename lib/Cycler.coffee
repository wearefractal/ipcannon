{EventEmitter} = require 'events'

class Cycler extends EventEmitter
  constructor: ({@source, @prefix}) ->
    @source ?= ['localhost']
    #@prefix ?= 'fd40:06b3:c15c:0c2f'
    
  # TODO: Support for ipv4 ranges
  getIP: ->
    if @prefix?
      rand = -> (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)
      out = "#{@prefix}"
      out += ":#{rand()}" while out.split(':').length < 8
      return out
    else # No prefix, select random from list
      @source[Math.floor(Math.random()*@source.length)]
      
module.exports = Cycler
