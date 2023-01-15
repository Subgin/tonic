const path = require('path')

module.exports = {
  entry: {
    application: [
      './source/javascripts/application.js',
      './source/stylesheets/application.css'
    ]
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].js'
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader',
          {
            loader: 'postcss-loader',
            options: {
              postcssOptions: {
                plugins: ['autoprefixer', 'tailwindcss']
              }
            }
          }
        ]
      },
      {
        test: /\.m?js/,
        resolve: {
          fullySpecified: false,
        }
      }
    ]
  }
}
