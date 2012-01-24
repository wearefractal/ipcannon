{EventEmitter} = require 'events'
Cycler = require './Cycler'
{net} = require 'ipbind'
os = require 'os'
bouncy = require 'bouncy'

class Proxy extends EventEmitter
  constructor: ({@interface, @host, @port, @maxConnections, @source}) ->
    if @interface?
      int = os.networkInterfaces()[@interface]
      throw 'Invalid interface' if !Array.isArray int
      @host = int[0].address
    @host ?= 'localhost'
    @port ?= 80
    @cycler = new Cycler({source: @source})

  getHost: -> @bouncer.address().address
  getPort: -> @bouncer.address().port
  getBlocked: -> [@getHost(), @host]

  launch: ->
    @bouncer = bouncy @handleRequest
    @bouncer.on 'listening', =>
      @bouncer.maxConnections = @maxConnections if @maxConnections?
      @bouncer.on 'request', (req) => @emit 'request', req
      @bouncer.on 'close', => @emit 'close'
      @emit 'ready', @getHost(), @getPort()
      
    @bouncer.listen @port, @host
  
  close: -> @bouncer.close()
  
  handleRequest: (req, bounce) =>
    error = (msg) -> 
      res = bounce.respond()
      res.writeHead 400
      res.end msg
      
    error 'missing host' unless req.headers.host?
    [host, port] = req.headers.host.split ':'
    port ?= 80
    error 'bad host' if host in @getBlocked()
    req.on 'error', => bounce.error 'invalid request'
    stream = net.createConnection port, host, @cycler.getIP()
    bounce stream
      
module.exports = Proxy
