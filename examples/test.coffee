{Proxy} = require '../index'
http = require 'http'
log = require 'node-log'
log.setName 'ipcannon-test'

Benchmark = require 'benchmark'

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
  
  sendRequest = =>
    options =
      host: host
      port: port
      headers:
        host: 'checkip.dyndns.org'
        #host: 'www.google.com'
      
    http.get options
      
  suite = new Benchmark.Suite
  suite.add "Proxy#handleRequest", -> sendRequest()
    
  suite.on "cycle", (event, bench) -> log.info String(bench)
  suite.on "complete", -> console.log "Fastest is " + @filter("fastest").pluck("name")
  suite.run async: true
  
proxy.launch()
