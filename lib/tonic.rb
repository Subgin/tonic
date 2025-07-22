require "yaml"
require "open-uri"
require "csv"

require_relative "tonic/utils"
require_relative "tonic/helpers"
require_relative "tonic/filters"

module Tonic
  VERSION = "0.21.0"
  REPO = "https://github.com/Subgin/tonic"
  MAGIC_ATTRS = %w(name description images category tags id dom_id detail_page_link)
  SKIP_FOR_FILTERS = MAGIC_ATTRS - %w(category tags)
  DEFAULT_COLOR = "#3e76d1"
  DEFAULT_BG_COLOR = "#f3f4f6"
  DEFAULT_ORDER = "name asc"
  SHARING_PLATFORMS = %w(facebook x reddit linkedin pinterest whatsapp telegram email)

  def self.start(context)
    # Inject helpers
    context.helpers Tonic::Utils, Tonic::Helpers, Tonic::Filters

    # Fetch remote collection if any
    if collection_url = raw_config["remote_collection"]
      remote_collection = URI.open(collection_url).read rescue nil
      File.write("data/collection.yaml", remote_collection) if remote_collection
    end

    # Check for CSV collection and convert to YAML
    if File.exist?("data/collection.csv")
      convert_csv_to_yaml
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

  def self.convert_csv_to_yaml
    begin
      csv_data = CSV.read("data/collection.csv", headers: true)
      collection = csv_data.map do |row|
        item = {}
        row.each do |key, value|
          next if value.nil? || value.strip.empty?
          
          # Handle special fields that should be arrays
          if key == "tags" || key == "images"
            item[key] = value.split(",").map(&:strip)
          # Handle numeric fields - be more flexible with numeric detection
          elsif value.match?(/^\d+(\.\d+)?$/)
            item[key] = value.include?(".") ? value.to_f : value.to_i
          # Handle boolean fields
          elsif value.downcase == "true" || value.downcase == "false"
            item[key] = value.downcase == "true"
          else
            item[key] = value
          end
        end
        item
      end
      
      File.write("data/collection.yaml", collection.to_yaml)
    rescue CSV::Error => e
      raise "[Tonic] Error parsing CSV file: #{e.message}"
    rescue StandardError => e
      raise "[Tonic] Error converting CSV to YAML: #{e.message}"
    end
  end

  def self.raw_config
    @raw_config ||= YAML.load_file("data/config.yaml")
  end
end
