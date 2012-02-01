{EventEmitter} = require 'events'
{exec} = require 'child_process'

rand = -> (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

class Cycler extends EventEmitter
  constructor: ({@source, @prefix}) ->
    #@source ?= ['localhost']
    if @source?
      exec "ifconfig eth0:#{idx} up #{ip} netmask 255.255.255.0" for ip, idx in @source[0..50]
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
