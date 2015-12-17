require! <[express]>
Promise = require 'bluebird'
fs = Promise.promisify-all require 'fs'
{knex} = require './knex'

export webserver = (app = express!) ->
  app.set 'views', 'app/views'
  app.set 'view engine', 'jade'
  app.get '/', (req, res) ->
    res.render 'index'
  app.get '/item', (req, res) ->
    knex.select 'id' 'name' 'desc' .from 'items'
    .then ->  res.json it
    .catch -> res.status \403 .send 'err'
  app.get '/price', (req, res) ->
    knex.select 'name' 'amazon' 'new' 'used' 'refurbished' 'recorded_time'
    .from 'amazon_price' .left-join 'items' 'amazon_price.item_id' 'items.id'
    .order-by 'recorded_time'
    .then ->  res.json it
    .catch -> res.status \403 .send 'err'
  app.use '/assets/js',  express.static \_public/js

export run-server = ->
  server = require \http .create-server webserver!
  (args = Array::slice.call arguments).unshift process.env.PORT
  server.listen.apply server, args
  server

if process?argv?1 is /app(.(js|ls))?$/
  run-server -> console.log "Running on port #{@address!port}"
