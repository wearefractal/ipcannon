{EventEmitter} = require 'events'
{networkInterfaces} = require 'os'
Cycler = require './Cycler'
{debase64} = require './util'
bouncy = require 'trouncy'
{net} = require 'ipbind'

class Proxy extends EventEmitter
  constructor: ({@interface, @host, @port, @maxConnections, @cycler}) ->
    # Parse ip from interface if given
    if @interface?
      int = networkInterfaces()[@interface]
      throw 'Invalid interface' if !Array.isArray int
      @host = int[0].address
      
    @host ?= 'localhost'
    @port ?= 80
    @cycler ?= new Cycler

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
      @emit 'ready', @getHost(), @getPort(), (@source or @prefix)
      
    @bouncer.listen @port, @host
  
  close: -> @bouncer.close()
  
  handleRequest: (req, bounce) =>
    error = (msg) -> 
      res = bounce.respond()
      res.writeHead 400
      res.end msg
      
    return error 'missing target' unless req.headers and req.headers.target
    matches = String(req.headers.target).match /^(?:http:\/\/)?([^:\/]+)?(?::(\d+))?((\/.+)|(\/))?$/
    return error 'invalid target' unless matches and matches[1]
    host = matches[1]
    port = matches[2] or 80
    path = matches[3] or '/'
    return error 'bad target' if host in @getBlocked()
    req.on 'error', => return error 'invalid request'
    if req.headers.session
      ip = debase64 req.headers.session
      session = req.headers.session
    else
      [ip, session] = @cycler.getIP host
    stream = net.createConnection port, host, ip
    opts = 
      host: host
      port: port
      path: path
      responseHeaders:
        session: session
        
    bounce stream, opts
    @emit 'request', req
      
module.exports = Proxy
