require "lib/tonic"

activate :directory_indexes
activate :inline_svg
activate :external_pipeline,
         name: :esbuild,
         command: build? ? "yarn build" : "yarn dev",
         source: "dist",
         latency: 1

configure :development do
  activate :livereload
end

configure :build do
  ignore File.join(config[:js_dir], "*") # handled by External Pipeline
  activate :asset_hash
  activate :relative_assets
end

Tonic.start(self)
