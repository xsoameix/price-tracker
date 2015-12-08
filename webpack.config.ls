module.exports =
  entry: './app/app.ls'
  output:
    path: '_public/js'
    filename: 'app.js'
  module:
    loaders:
      * test: /\.ls$/
        loader: 'livescript'
      * test: /\.styl$/
        loader: 'style!css!stylus'
  resolve:
    extensions: ['', '.js', '.ls']
