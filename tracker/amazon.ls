require! <[url cheerio money moment]>
request = require 'request-promise'
Promise = require 'bluebird'
fs = Promise.promisify-all require 'fs'
{load-item} = require './amazon.lib'

get-price = (itemid) ->
  request "http://www.amazon.com/gp/product/#itemid"
  .then ->
    $ = cheerio.load it
    price = amazon: money $('#priceblock_ourprice').text! .convert!
    span = $('#olp_feature_div > div > span')
    span.each ->
      cond = url.parse($(@).find('a').attr('href'), true).query.condition
      price[cond] = money $(@).find('span').text! .convert!
    price

update-price = (itemid) ->
  file = 'tracker/amazon.json'
  fs.read-file-async file, 'utf8'
  .bind {}
  .then ->
    @json = JSON.parse it
    Promise.all itemid.map ->
      get-price it
  .then (price) ->
    itemid.for-each (id, i) ~>
      item = @json[id] || []
      @json[id] = item ++ price[i] <<< created_time: moment!format!
    fs.write-file-async file, JSON.stringify @json
  .then ->
    console.log 'saved.'

update-record = ->
  load-item!
  .then ->
    update-price it.map (.id)
  .catch ->
    console.log it

update-record!

#request do
#  url: 'http://webservices.amazon.com/onca/xml'
#  qs:
#    Service: 'AWSECommerceService'
#    Operation: 'ItemLookup'
#    ResponseGroup: 'Offers'
#    IdType: 'ASIN'
#    ItemId: 'B00KOKTZLQ'
#    AssociateTag: [Your_AssociateTag]
#    AWSAccessKeyId: [Your_AWSAccessKeyId]
#    Timestamp: [YYYY-MM-DDThh:mm:ssZ]
#    Signature: [Request_Signature]
#.then ->
#  console.log it
#.catch ->
#  console.log it
