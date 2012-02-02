module.exports =
  base64: (str) -> new Buffer(str).toString 'base64'
  debase64: (str) -> new Buffer(str, 'base64').toString 'ascii'
