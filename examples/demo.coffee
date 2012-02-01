get = require 'get'
log = require 'node-log'
log.setName 'cannon-demo'


options =
  uri: 'http://216.19.216.2'
  headers:
    target: 'checkip.dyndns.org'
    
dl = new get options
      
dl.asString (err, res) ->
  throw err if err?
  log.debug res
