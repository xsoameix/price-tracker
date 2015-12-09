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
      * test: /\.css$/
        loader: 'style!css'
      * test: /\.jpe?g$|\.png$|\.svg$|\.woff2?$|\.ttf$|\.eot$/
        loader: 'url'
  resolve:
    extensions: ['', '.js', '.ls']
