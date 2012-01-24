{Proxy} = require '../index'
http = require 'http'
log = require 'node-log'
log.setName 'ipcannon-test'

proxy = new Proxy 
  host: '127.0.0.1'
  port: 8080
  #source: ['192.168.1.101']
  prefix: 'fd40:06b3:c15c:0c2f'

# Event handling
proxy.on 'request', (req) -> log.debug "Proxying request to #{req.headers.host}"
  
proxy.on 'error', (err, req) -> log.error err

proxy.on 'ready', (host, port) -> 
  log.info "Proxy started on #{host}:#{port}"
  
  # Send test request
  options =
    host: host
    port: port
    path: '/ip/'
    headers:
      #host: 'checkip.dyndns.org'
      host: 'queryip.net'
    
  http.get options, (res) ->
    res.setEncoding "utf8"
    body = ''
    res.on 'data', (chunk) -> body += chunk
    res.on 'end', -> log.debug body
    
proxy.launch()
