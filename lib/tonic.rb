module Tonic
  VERSION = "0.8.3"
  REPO = "https://github.com/Subgin/tonic"
  MAGIC_ATTRS = %w(name description images category tags id dom_id)
  SKIP_FOR_FILTERS = MAGIC_ATTRS - %w(category tags)
  DEFAULT_COLOR = "#3e76d1"
  DEFAULT_ORDER = "name asc"

  def self.start(context)
    context.helpers Helpers

    context.data.collection.each do |item|
      context.proxy "/#{Helpers.slugify(item.name)}.html", "/templates/collection/item_page.html", locals: { item: item }, ignore: true
    end
  end

  module Helpers
    extend self

    def slugify(text)
      text.parameterize
    end

    def tonic_collection
      data.collection.each do |item|
        item.id = slugify(item.name)
        item.dom_id = "item_#{item.id}"
      end
    end

    def config
      data.config.reverse_merge(
        title: "Tonic Example",
        item_card: { image: true },
        sorting: { default_order: DEFAULT_ORDER }
      )
    end

    def render_filters
      attributes = tonic_collection.map(&:keys).flatten.uniq.sort

      attributes.map do |attribute|
        next if SKIP_FOR_FILTERS.include?(attribute)
        next if config.filters&.exclude&.include?(attribute)

        content_tag(:div, class: "px-6 py-3 border-b border-gray-500 w-full") do
          type = config.filters&.type&.dig(attribute)
          smart_filter(attribute, type)
        end
      end.compact.join
    end

    def smart_filter(attribute, type = nil)
      # Take sample value from 1st element
      value = tonic_collection[0][attribute]

      if !type
        type = "numeric_range" if value.is_a?(Numeric)
        type = "tags" if value.is_a?(Array)
        type = "boolean" if is_bool?(value)
        type = smart_text_filter(attribute, value) if value.is_a?(String)
      end

      public_send("#{type}_filter", attribute)
    end

    def smart_text_filter(attribute, value)
      if attribute == "category"
        "select"
      elsif attribute.end_with?("_at") && is_date?(value)
        "date_range"
      elsif single_word?(value) && !is_url?(value)
        uniq_values = tonic_collection.map(&:"#{attribute}").compact.uniq.size
        uniq_values >= 5 ? "select" : "radio_buttons"
      else
        "text"
      end
    end

    def label(attribute)
      content_tag(:label, attribute.humanize.capitalize, class: "text-white py-1")
    end

    def text_filter(attribute)
      partial("templates/filters/text", locals: { attribute: attribute })
    end

    def numeric_range_filter(attribute)
      range = tonic_collection.map(&:"#{attribute}").compact.uniq
      min = range.min
      max = range.max

      partial("templates/filters/numeric_range", locals: { attribute: attribute, min: min, max: max })
    end

    def date_range_filter(attribute)
      range = tonic_collection.map(&:"#{attribute}").compact.uniq
      min = range.min
      max = range.max

      partial("templates/filters/date_range", locals: { attribute: attribute, min: min, max: max })
    end

    def tags_filter(attribute)
      tags = tonic_collection.flat_map(&:"#{attribute}").compact.uniq.sort

      partial("templates/filters/tags", locals: { attribute: attribute, tags: tags })
    end

    def select_filter(attribute)
      options = tonic_collection.flat_map(&:"#{attribute}").uniq
      options = ["All"] + options.sort

      partial("templates/filters/select", locals: { attribute: attribute, options: options })
    end

    def boolean_filter(attribute)
      partial("templates/filters/boolean", locals: { attribute: attribute })
    end

    def radio_buttons_filter(attribute)
      options = tonic_collection.flat_map(&:"#{attribute}").uniq
      options = ["All"] + options.sort

      partial("templates/filters/radio_buttons", locals: { attribute: attribute, options: options })
    end

    def rest_of_attrs(item)
      (item.keys - MAGIC_ATTRS).sort
    end

    def sorting_options
      options = tonic_collection[0].select { |k, v| k == 'name' || v.is_a?(Numeric) }.keys

      if exclude = config.sorting.exclude
        options = options - exclude
      end

      options.map do |option|
        ["#{option.titleize} ASC", "#{option.titleize} DESC"]
      end.flatten.sort
    end

    def strip_truncate(html, length = 50)
      truncate(strip_tags(html), length: length)
    end

    def render_tags(tags)
      return if !tags

      tags.sort.map do |tag|
        "<span class='tag'>#{tag}</span>"
      end.join(" ")
    end

    def is_bool?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end

    def is_date?(value)
      Date.parse(value)
    rescue Date::Error
      false
    end

    def is_url?(string)
      string =~ URI::regexp
    end

    def single_word?(string)
      !string.strip.include? " "
    end
  end
end
