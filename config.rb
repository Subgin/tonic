require "lib/tonic"

activate :directory_indexes

activate :external_pipeline,
         name: :webpack,
         command: build? ? 'yarn run build' : 'yarn run start',
         source: 'dist',
         latency: 1

configure :development do
  activate :livereload
end

configure :build do
  ignore File.join(config[:js_dir], '*') # handled by Webpack
  activate :asset_hash
  activate :minify_css
  activate :relative_assets
end

Tonic.start(self)
