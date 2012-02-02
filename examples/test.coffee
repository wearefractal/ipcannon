{Proxy, Cycler} = require '../index'
http = require 'http'
log = require 'node-log'
log.setName 'ipcannon-test'
Benchmark = require 'benchmark'

cycler = new Cycler prefix: 'fd40:06b3:c15c:0c2f'
  
proxy = new Proxy 
  host: '127.0.0.1'
  port: 8080
  cycler: cycler

# Event handling
proxy.on 'request', (req) -> log.debug "Proxying request to #{req.headers.target}"
  
proxy.on 'error', (err, req) -> log.error err

proxy.on 'ready', (host, port, ips) -> 
  log.info "Proxy started on #{host}:#{port}"
  options =
    host: '127.0.0.1'
    port: 8080
    headers:
      target: 'http://checkip.dyndns.org/'
      #session: 'something'
      
  http.get options, (res) ->
    buff = ''
    console.log res.headers
    res.on 'data', (chunk) -> buff += chunk
    res.on 'end', -> log.info "Response: #{buff}"
    
proxy.launch()
