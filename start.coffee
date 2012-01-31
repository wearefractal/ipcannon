{Proxy, Cycler} = require './index'
http = require 'http'
log = require 'node-log'
log.setName 'ipcannon'

# Demo: 216.19.216.3-254
range = []
range.push "216.19.216.#{x}" for x in [3..254]

proxy = new Proxy 
  host: '127.0.0.1'
  port: 8080
  source: range

# Event handling
proxy.on 'request', (req) -> log.debug "Proxying request to #{req.headers.host}"
proxy.on 'error', (err, req) -> log.error err
proxy.on 'ready', (host, port) -> log.info "Proxy started on #{host}:#{port}"
  
proxy.launch()
