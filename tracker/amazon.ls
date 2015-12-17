require! <[url cheerio money moment ./chrome-meta]>
request = require 'request-promise'
Promise = require 'bluebird'
fs = Promise.promisify-all require 'fs'
{knex} = require '../server/knex'
cron = require 'cron' .CronJob

load-item = ->
  knex.select 'id' 'name' .from 'items'

rand-num = (max, min = 1) -> Math.floor(Math.random! * (max - min + 1)) + min
rand-pick = -> it[Math.floor(Math.random! * it.length)]

gen-user-agent = ->
  linux = -> "X11; Ubuntu; Linux x86_64"
  windows = -> "Windows NT #{rand-pick <[6.1 6.2 6.3 10.0]>}; WOW64"
  os = rand-pick([linux, windows])!
  firefox = ->
    rv = rand-num 42
    "Mozilla/5.0 (#os; rv:#rv.0) Gecko/20100101 Firefox/#rv.0"
  chrome = ->
    tag = rand-pick chrome-meta.tag
    rv = "#{tag.ver}.0.#{rand-num.apply null, tag.range}.0"
    w = '537.36'
    "Mozilla/5.0 (#os) AppleWebKit/#w (KHTML, like Gecko) Chrome/#rv Safari/#w"
  rand-pick([firefox, chrome])!

get-price = (itemid) ->
  var price
  request do
    url: "http://www.amazon.com/gp/product/#itemid"
    headers:
      'Host': 'www.amazon.com'
      'User-Agent': gen-user-agent!
      'Accept': 'text/html'
  .then ->
    if it == /Sorry, we just need to make sure you\'re not a robot/
      throw Error 'Detected as a robot'
    $ = cheerio.load it
    amazon = money $('#priceblock_ourprice').text! .convert!
    if !(typeof amazon != 'undefined' && amazon@@ == Number && amazon > 0)
      throw Error "No price availble: #itemid"
    price := {amazon}
    span = $('#olp_feature_div > div > span')
    span.each ->
      cond = url.parse($(@).find('a').attr('href'), true).query.condition
      price[cond] := money $(@).find('span').text! .convert!
    request do
      url: "http://www.amazon.com/gp/offer-listing/#itemid/ref=olp_page_1?f_new=true"
      headers:
        'Host': 'www.amazon.com'
        'User-Agent': gen-user-agent!
        'Accept': 'text/html;q=0.9,*/*;q=0.8'
  .then ->
    $ = cheerio.load it
    new-price = $('.olpOfferPrice').map ->
      money $(@).text! .convert!
    the-price = Math.min.apply null, new-price
    if new-price.length > 0 && !Number.isNaN the-price
      price.new = the-price
    if Number.isNaN price.new
      delete price.new
    price

update-price = (itemid) ->
  Promise.all itemid.map ->
    get-price it.name
  .then (price) ->
    attr = recorded_time: moment!format!
    records = itemid.map (e, i) -> {item_id: e.id} <<< price[i] <<< attr
    knex 'amazon_price' .insert records

update-record = ->
  load-item!
  .then ->
    update-price it
  .catch ->
    if it.name == 'RequestError'
      console.log 'The network is down.'
    else
      console.log it.stack

new cron do
  cron-time: '00 * * * * *'
  on-tick: ->
    request.defaults({+jar}) 'http://www.amazon.com'
    .then ->
      update-record!
  start: true
  time-zone: 'Asia/Taipei'
.start!

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
