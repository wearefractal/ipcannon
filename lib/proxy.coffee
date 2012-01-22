{EventEmitter} = require 'events'
os = require 'os'
bouncy = require 'bouncy'

class Proxy extends EventEmitter
  constructor: ({@interface, @host, @port, @maxConnections}) ->
    if @interface?
      int = os.networkInterfaces()[@interface]
      throw 'Invalid interface' if !Array.isArray int
      @host = int[0].address
    @host ?= 'localhost'
    @port ?= 80

  getHost: -> @bouncer.address().address
  getPort: -> @bouncer.address().port
  getBlocked: -> [@getHost(), @host]
  
  launch: ->
    @bouncer = bouncy @handleRequest
    @bouncer.listen @port, @host
    @bouncer.on 'listening', =>
      @bouncer.maxConnections = @maxConnections if @maxConnections?
      @bouncer.on 'request', (req) => @emit 'request', req
      @bouncer.on 'close', => @emit 'close'
      @emit 'ready', @getHost(), @getPort()
  
  close: -> @bouncer.close()
  
  handleRequest: (req, bounce) =>
    if req.headers.host?
      [host, port] = req.headers.host.split ':'
      if host in @getBlocked()
        res = bounce.respond()
        res.statusCode = 400
        res.end 'bad host'
      else
        bounce host, port
        req.on 'error', =>
          res = bounce.respond()
          res.statusCode = 400
          res.end 'invalid request'
    else
      res = bounce.respond()
      res.statusCode = 400
      res.end 'missing host'
      
module.exports = Proxy
