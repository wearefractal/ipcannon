{EventEmitter} = require 'events'
{exec} = require 'child_process'
{base64} = require './util'

rand = -> (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

class Cycler extends EventEmitter
  constructor: ({@source, @prefix, @blacklist}) ->
    if @source?
      exec "ifconfig eth0:#{idx} up #{ip} netmask 255.255.255.0" for ip, idx in @source
    @source ?= ['localhost']
    @blacklist ?= {}
    #  'google.com': ['ip1', 'ip2']
    @range = 8 - @prefix.split(':').length if @prefix?
    
  # TODO: Support for ipv4 ranges
  getIP: (host) ->
    if @prefix
      out = @prefix
      out += ":#{rand()}" for num in @range
    else # No prefix, select random from list of ipv4
      out = @source[Math.floor(Math.random()*@source.length)]
    return @getIP host if @blacklist[host] and out in @blacklist[host]
    return [out, base64 out]
    
module.exports = Cycler
