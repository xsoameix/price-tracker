require! <[express]>
Promise = require 'bluebird'
fs = Promise.promisify-all require 'fs'

export webserver = (app = express!) ->
  app.set 'views', 'app/views'
  app.set 'view engine', 'jade'
  app.get '/', (req, res) ->
    res.render 'index'
  app.get '/price', (req, res) ->
    fs.read-file-async 'tracker/amazon.json', 'utf8'
    .then ->
      res.json JSON.parse it
    .catch ->
      res.status \403 .send 'err'
  app.use '/assets/js',  express.static \_public/js

export run-server = ->
  server = require \http .create-server webserver!
  (args = Array::slice.call arguments).unshift process.env.PORT
  server.listen.apply server, args
  server

if process?argv?1 is /app(.(js|ls))?$/
  run-server -> console.log "Running on port #{@address!port}"
