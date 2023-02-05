module Tonic
  module Filters
    def render_filters
      attributes = tonic_collection.flat_map(&:keys).uniq.sort

      attributes.map do |attribute|
        next if Tonic::SKIP_FOR_FILTERS.include?(attribute)
        next if config.filters&.exclude&.include?(attribute)

        content_tag(:div, class: "px-6 py-3 border-b border-gray-500 w-full") do
          type = config.filters&.type&.dig(attribute)
          smart_filter(attribute, type)
        end
      end.compact.join
    end

    private

    def smart_filter(attribute, type = nil)
      # Take sample value from 1st element
      value = tonic_collection[0][attribute]

      if !type
        type = "numeric_range" if value.is_a?(Numeric)
        type = "tags" if value.is_a?(Array)
        type = "boolean" if is_bool?(value)
        type = "text" if is_hash?(value)
        type = smart_text_filter(attribute, value) if value.is_a?(String)
      end

      send("#{type}_filter", attribute)
    end

    def smart_text_filter(attribute, value)
      if attribute == "category"
        "select"
      elsif attribute.end_with?("_at") && is_date?(value)
        "date_range"
      elsif single_word?(value) && !is_url?(value) && !is_email?(value)
        uniq_values = fetch_values(attribute).size
        uniq_values >= 5 ? "select" : "radio_buttons"
      else
        "text"
      end
    end

    def label(attribute)
      content_tag(:label, attribute.humanize, class: "text-white py-1")
    end

    def text_filter(attribute)
      partial("templates/filters/text", locals: { attribute: attribute })
    end

    def numeric_range_filter(attribute)
      range = fetch_values(attribute)
      min = range.min
      max = range.max

      partial("templates/filters/numeric_range", locals: { attribute: attribute, min: min, max: max })
    end

    def date_range_filter(attribute)
      range = fetch_values(attribute)
      min = range.min
      max = range.max

      partial("templates/filters/date_range", locals: { attribute: attribute, min: min, max: max })
    end

    def tags_filter(attribute)
      tags = fetch_values(attribute).sort

      partial("templates/filters/tags", locals: { attribute: attribute, tags: tags })
    end

    def select_filter(attribute)
      options = fetch_values(attribute)
      options = ["All"] + options.sort

      partial("templates/filters/select", locals: { attribute: attribute, options: options })
    end

    def boolean_filter(attribute)
      partial("templates/filters/boolean", locals: { attribute: attribute })
    end

    def radio_buttons_filter(attribute)
      options = fetch_values(attribute)
      options = ["All"] + options.sort

      partial("templates/filters/radio_buttons", locals: { attribute: attribute, options: options })
    end

    def fetch_values(attribute)
      tonic_collection.flat_map(&:"#{attribute}").compact.uniq
    end
  end
end
