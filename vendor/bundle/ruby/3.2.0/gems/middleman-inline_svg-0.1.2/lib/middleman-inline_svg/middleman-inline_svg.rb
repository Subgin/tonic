require "middleman-inline_svg/inline_svg"

class MiddlemanInlineSVG < ::Middleman::Extension
  expose_to_template :inline_svg

  option :defaults, {}, "Default options for the svg"

  def initialize(app, options_hash = {}, &block)
    super
  end

  def inline_svg(file_name, opts = {})
    opts = options.defaults.merge(opts)

    InlineSVG.new(asset_file(file_name), opts).to_html
  end

  private

  def asset_file(file_name)
    File.open(File.join(file_path, file_name))
  end

  def file_path
    File.join(app.config[:source], app.config[:images_dir])
  end
end
