{EventEmitter} = require 'events'
Cycler = require './Cycler'
{net} = require 'ipbind'
os = require 'os'
bouncy = require 'bouncy'

class Proxy extends EventEmitter
  constructor: ({@interface, @host, @port, @maxConnections, @source, @cycler, @prefix}) ->
    # Parse ip from interface if given
    if @interface?
      int = os.networkInterfaces()[@interface]
      throw 'Invalid interface' if !Array.isArray int
      @host = int[0].address
      
    @host ?= 'localhost'
    @port ?= 80
    @cycler ?= new Cycler source: @source, prefix: @prefix

  # Get IP of proxy
  getHost: -> @bouncer.address().address
  
  # Get port of proxy
  getPort: -> @bouncer.address().port
  
  # Don't enter an infinite loop of requests by bouncing to ourselves
  # TODO: Expand thi into a true blacklist
  getBlocked: -> [@getHost(), @host]

  # Start listening for and bouncing requests
  launch: ->
    @bouncer = bouncy @handleRequest
    @bouncer.on 'listening', =>
      @bouncer.maxConnections = @maxConnections if @maxConnections?
      #@bouncer.on 'request', (req) => @emit 'request', req
      @bouncer.on 'close', => @emit 'close'
      @emit 'ready', @getHost(), @getPort()
      
    @bouncer.listen @port, @host
  
  close: -> @bouncer.close()
  
  handleRequest: (req, bounce) =>
    error = (msg) -> 
      res = bounce.respond()
      res.writeHead 400
      res.end msg
      
    error 'missing host' unless req.headers.target?
    if (m = req.headers.target.match(/^(?:http:\/\/)?([^:\/]+)?(?::(\d+))?(\/.+)?$/)) and m[1]
      host = m[1]
      port = m[2] or 80
      path = m[3] or '/'
    else
      error 'invalid host'
    port ?= 80
    error 'bad host' if host in @getBlocked()
    req.on 'error', => bounce.error 'invalid request'
    stream = net.createConnection port, host, @cycler.getIP()
    opts = 
      host: host
      port: port
      path:  path
      headers:
        "x-forwarded-for": undefined
        "x-forwarded-port": undefined
        "x-forwarded-proto": undefined
        
    bounce stream, opts
    @emit 'request', req
      
module.exports = Proxy
