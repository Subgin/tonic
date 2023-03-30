require "yaml"
require "open-uri"

require_relative "tonic/utils"
require_relative "tonic/helpers"
require_relative "tonic/filters"

module Tonic
  VERSION = "0.17.1"
  REPO = "https://github.com/Subgin/tonic"
  MAGIC_ATTRS = %w(name description images category tags id dom_id detail_page_link)
  SKIP_FOR_FILTERS = MAGIC_ATTRS - %w(category tags)
  DEFAULT_COLOR = "#3e76d1"
  DEFAULT_BG_COLOR = "#f3f4f6"
  DEFAULT_ORDER = "name asc"
  SHARING_PLATFORMS = %w(facebook twitter linkedin pinterest whatsapp telegram email)

  def self.start(context)
    # Inject helpers
    context.helpers Tonic::Utils, Tonic::Helpers, Tonic::Filters

    # Fetch remote collection if any
    if collection_url = raw_config["remote_collection"]
      remote_collection = URI.open(collection_url).read rescue nil
      File.write("data/collection.yaml", remote_collection) if remote_collection
    end

    # Create a detail page for each item if enabled
    if raw_config.fetch("detail_pages", true)
      context.data.collection.each do |item|
        context.proxy "/#{Tonic::Utils.slugify(item.name)}.html", "/templates/collection/detail_page.html", locals: { item: item }
      end
    end

    # Do not build detail page template
    context.ignore "/templates/collection/detail_page.html"
  end

  private

  def self.raw_config
    @raw_config ||= YAML.load_file("data/config.yaml")
  end
end
