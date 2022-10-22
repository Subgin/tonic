module Tonic
  VERSION = "0.1.0"
  REPO = "https://github.com/Subgin/tonic"
  MAGIC_ATTRS = %w(name description images category tags id dom_id)
  SKIP_FOR_FILTERS = MAGIC_ATTRS - %w(category tags)
  DEFAULT_COLOR = "#1d4ed8"
  DEFAULT_ORDER = "name_asc"

  def self.start(context)
    context.helpers Helpers

    context.data.collection.each do |item|
      context.proxy "/#{Helpers.slugify(item.name)}", "/templates/collection/item_page.html", locals: { item: item }, ignore: true
    end
  end

  module Helpers
    extend self

    def tonic_collection
      data.collection.each do |item|
        item.id = slugify(item.name)
        item.dom_id = "item_#{item.id}"
      end
    end

    def sort_collection(collection)
      default_order = data.config.sorting&.default_order
      attribute, direction = (default_order || DEFAULT_ORDER).split("_")
      type = collection[0][attribute]

      collection.sort_by do |item|
        if direction == "asc"
          type.is_a?(Integer) ? item[attribute].to_i : item[attribute].to_s.downcase
        else
          type.is_a?(Integer) ? -item[attribute].to_i : -item[attribute].to_s.downcase
        end
      end
    end

    def render_filters
      attributes = tonic_collection.map(&:keys).flatten.uniq.sort

      attributes.map do |attribute|
        next if SKIP_FOR_FILTERS.include?(attribute)
        next if data.config.filters&.exclude&.include?(attribute)

        content_tag(:div, class: "px-6 py-3 border-b border-gray-500 w-full") do |li|
          type = data.config.filters&.type&.dig(attribute)
          smart_filter(attribute, type)
        end
      end.compact.join
    end

    def smart_filter(attribute, type = nil)
      # Take sample value from 1st element
      value = tonic_collection[0][attribute]

      if !type
        type = "select"        if attribute == "category"
        type = "text"          if value.is_a?(String)
        type = "numeric_range" if value.is_a?(Integer)
        type = "tags"          if value.is_a?(Array)
        type = "boolean"       if is_bool?(value)
      end

      render_filter(type, attribute)
    end

    def render_filter(type, attribute)
      case type
      when "text"
        text_filter(attribute)
      when "numeric_range"
        numeric_range_filter(attribute)
      when "select"
        select_filter(attribute)
      when "tags"
        tags_filter(attribute)
      when "boolean"
        boolean_filter(attribute)
      end
    end

    def label(attribute)
      content_tag(:label, attribute.capitalize, class: "text-white py-1")
    end

    def text_filter(attribute)
      partial("templates/filters/text", locals: { attribute: attribute })
    end

    def numeric_range_filter(attribute)
      range = tonic_collection.map(&:"#{attribute}").compact.uniq
      min = range.min
      max = range.max

      partial("templates/filters/numeric_range", locals: { min: min, max: max, attribute: attribute })
    end

    def tags_filter(attribute)
      tags = tonic_collection.flat_map(&:"#{attribute}").compact.uniq.sort

      partial("templates/filters/tags", locals: { attribute: attribute, tags: tags })
    end

    def select_filter(attribute)
      options = tonic_collection.flat_map(&:"#{attribute}").uniq
      options = ["All"] + options.sort

      partial("templates/filters/select", locals: { options: options, attribute: attribute })
    end

    def boolean_filter(attribute)
      partial("templates/filters/boolean", locals: { attribute: attribute })
    end

    def slugify(text)
      text.parameterize
    end

    def rest_of_attrs(item)
      (item.keys - MAGIC_ATTRS).sort
    end

    def sorting_options
      options = tonic_collection[0].select { |k, v| k == 'name' || v.is_a?(Integer) }.keys

      if exclude = data.config.sorting&.exclude
        options = options - exclude
      end

      options.map do |option|
        ["#{option.titleize} ASC", "#{option.titleize} DESC"]
      end.flatten
    end

    def render_tags(tags)
      tags.sort.map do |tag|
        "<span class='tag'>#{tag}</span>"
      end.join(" ")
    end

    def is_bool?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end

    def is_url?(string)
      string =~ URI::regexp
    end
  end
end
