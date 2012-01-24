{Proxy, Cycler} = require '../index'
http = require 'http'
log = require 'node-log'
log.setName 'ipcannon-test'
Benchmark = require 'benchmark'

cycler = new Cycler prefix: 'fd40:06b3:c15c:0c2f'
  
cycler2 = new Cycler source: ['192.168.1.101']
  
proxy = new Proxy 
  host: '127.0.0.1'
  port: 8080
  cycler: cycler

# Event handling
proxy.on 'request', (req) -> log.debug "Proxying request to #{req.headers.host}"
  
proxy.on 'error', (err, req) -> log.error err

proxy.on 'ready', (host, port) -> 
  log.info "Proxy started on #{host}:#{port}"
  doReq = (suite) ->
    options =
      host: host
      port: port
      headers:
        host: 'checkip.dyndns.org'
        #host: 'www.google.com'
      
    http.get options, (res) ->
      
    
      
  suite = new Benchmark.Suite 'ipcannon'
  # suite.add "Proxy.handleRequest", => doReq suite
  suite.add "Cycler.getIP(prefix)", => cycler.getIP()
  suite.add "Cycler.getIP(source)", => cycler2.getIP()
  suite.on "error", (event, bench) -> throw bench.error
  suite.on "cycle", (event, bench) -> log.info String bench
  suite.on "complete", -> proxy.close()
    
  suite.run async: true
  
proxy.launch()
