module Tonic
  VERSION = "0.0.2"
  REPO = "https://github.com/Subgin/tonic"

  def self.run(context)
    context.helpers Helpers

    context.data.collection.each do |item|
      context.proxy "/#{Helpers.slugify(item.name)}", "/templates/collection/detail.html", locals: { item: item }, ignore: true
    end
  end

  module Helpers
    extend self

    def tonic_collection
      data.collection
    end

    def render_filters
      attributes = tonic_collection.map(&:keys).flatten.uniq

      attributes.map do |attribute|
        next if data.config.filters.exclude.include?(attribute)

        content_tag(:li) do |li|
          type = data.config.filters.type[attribute]
          render_filter(attribute, type)
        end
      end.compact.join("<br>")
    end

    def render_filter(attribute, type = nil)
      # HACK: take a sample value from first elem
      sample = tonic_collection[0][attribute]

      if type
        custom_filter(type, attribute)
      elsif sample.is_a?(String)
        text_filter(attribute)
      elsif sample.is_a?(Array)
        tags_filter(attribute)
      elsif sample.is_a?(Integer)
        numeric_filter(attribute)
      end
    end

    def label(attribute)
      attribute = data.config.filters.label[attribute] || attribute.capitalize
      content_tag(:label, attribute, class: "label")
    end

    def custom_filter(type, attribute)
      case type
      when "text"
        text_filter(attribute)
      when "numeric"
        number_filter(attribute)
      when "numeric_range"
        numeric_range_filter(attribute)
      when "select"
        select_filter(attribute)
      when "slider_range"
        slider_range_filter(attribute)
      when "tags"
        tags_filter(attribute)
      when "boolean"
        boolean_filter(attribute)
      end
    end

    def text_filter(attribute)
      label(attribute) +
      input_tag(:text, onkeyup: "filter.text(this.value, '#{attribute}')", class: "input")
    end

    def numeric_filter(attribute)
      label(attribute) +
      input_tag(:number, name: attribute, onkeyup: "numericFilter(this.value, '#{attribute}')", class: "input")
    end

    def numeric_range_filter(attribute)
      range = tonic_collection.map(&:"#{attribute}").compact.uniq
      min = range.min
      max = range.max

      label(attribute) +
      partial("templates/filters/numeric_range", locals: { min: min, max: max, attribute: attribute })
    end

    def tags_filter(attribute)
      tags = tonic_collection.flat_map(&:"#{attribute}").uniq

      label(attribute) +
      partial("templates/filters/tags", locals: { tags: tags })
    end

    def select_filter(attribute)
      options = tonic_collection.flat_map(&:"#{attribute}").uniq
      options = ["all"] + options

      label(attribute) +
      select_tag(attribute, name: attribute, options: options, onchange: "filter.type(this.value, '#{attribute}')")
    end

    def slider_range_filter(attribute)
      range = tonic_collection.map(&:"#{attribute}").uniq
      min = range.min
      max = range.max

      label(attribute) +
      partial("templates/filters/slider_range", locals: { min: min, max: max, attribute: attribute })
    end

    def boolean_filter(attribute)
      label(attribute) +
      partial("templates/filters/boolean", locals: { attribute: attribute })
    end

    def identify(elem)
      "id='#{slugify(elem.name)}'"
    end

    def slugify(text)
      text.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end
end
