{get} = require 'http'
log = require 'node-log'
log.setName 'cannon-demo'

options =
  hostname: '216.19.216.2'
  headers:
    target: 'http://checkip.dyndns.org'
      
get options, (res) ->
  res.setEncoding 'utf8'
  body = ''
  res.on 'data', (chunk) -> body += chunk
  res.on 'end', -> log.debug body
