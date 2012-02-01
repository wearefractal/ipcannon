#/opt/node/bin node
{Proxy, Cycler} = require './index'
http = require 'http'
log = require 'node-log'
log.setName 'ipcannon'

# Demo: 216.19.216.3-254
range = []
range.push "216.19.216.#{x}" for x in [3..254]

proxy = new Proxy 
  host: '216.19.216.2'
  port: 80
  source: range

# Event handling
proxy.on 'request', (req) -> log.debug "Proxying request to #{req.headers.target}"
proxy.on 'error', (err, req) -> log.error err
proxy.on 'ready', (host, port, range) -> 
  log.info "Proxy started on #{host}:#{port} with IP range #{range}"
  
proxy.launch()
