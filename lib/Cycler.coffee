{EventEmitter} = require 'events'

class Cycler extends EventEmitter
  constructor: ({@source, @prefix}) ->
    @source ?= ['localhost']
  
  getIP: ->
    if @prefix?
      rand = -> (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)
      return "#{prefix}:#{rand()}:#{rand()}:#{rand()}:#{rand()}" 
      #TODO Ipv4/ipv6 detection and support for variable length prefix
    else # No prefix = testing
      @source[Math.floor(Math.random()*@source.length)]
      
module.exports = Cycler
