Promise = require 'bluebird'
fs = Promise.promisify-all require 'fs'

export load-item = ->
  file = 'tracker/amazon.items.json'
  fs.read-file-async file, 'utf8'
  .then ->
    JSON.parse it
