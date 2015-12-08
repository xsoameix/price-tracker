require! <[gaussian moment]>
Promise = require 'bluebird'
fs = Promise.promisify-all require 'fs'
{load-item} = require './amazon.lib'

update-price = (itemid) ->
  file = 'tracker/amazon.json'
  fs.read-file-async file, 'utf8'
  .then ->
    json = JSON.parse it
    itemid.for-each (id) ->
      time = moment [2012 6 30]
      dnorm = gaussian 0, 900
      dnorm = for i from -100 to 100
        dnorm.pdf i
      max = Math.max.apply {}, dnorm
      price = dnorm.map (x, i) ->
        time .= add 5, 'd'
        new: x / max * 100 + 100
        created_time: time.format!
      item = json[id] || []
      json[id] = item ++ price
    fs.write-file-async file, JSON.stringify json
  .then ->
    console.log 'generated.'

update-record = ->
  load-item!
  .then ->
    update-price it.map (.id)

update-record!
