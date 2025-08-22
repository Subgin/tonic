module Tonic
  module Helpers
    extend self

    def config
      data.config.reverse_merge(
        title: "Tonic Example",
        detail_pages: true,
        category_pages: true,
        item_card_image: true,
        sorting: { default_order: Tonic::DEFAULT_ORDER }
      )
    end

    def tonic_collection
      data.collection.each do |item|
        item.id = slugify(item.name)
        item.dom_id = "item_#{item.id}"

        validate_item!(item)
      end
    end

    def slugify(text)
      text&.parameterize
    end

    def rest_of_attrs(item)
      (item.keys - Tonic::MAGIC_ATTRS).sort
    end

    def detail_page_url(item)
      if item.detail_page_link.present?
        item.detail_page_link
      elsif config.detail_pages
        "/#{item.id}"
      end
    end

    def sorting_options
      options = tonic_collection[0].select do |k, v|
        k == "name" ||
        v.is_a?(Numeric) ||
        (v.is_a?(String) && k.end_with?("_at") && is_date?(v))
      end.keys

      if exclude = config.sorting.exclude
        options = options - exclude
      end

      options.flat_map do |option|
        ["#{option} asc", "#{option} desc"]
      end.sort
    end

    def sort_link(option)
      attribute, direction = option.split(" ")

      link_to "#{attribute.humanize} #{direction.upcase}", "#", onclick: "sortBy('#{option}')", data: { sort_by: option }
    end

    def sharing_platforms
      return Tonic::SHARING_PLATFORMS if !config.sharing_platforms

      Tonic::SHARING_PLATFORMS.select do |platform|
        config.sharing_platforms.include?(platform)
      end
    end

    def all_categories(collection)
      collection.to_a.map(&:category).compact.uniq.sort
    end

    def category_page_url(category)
      "/category/#{slugify(category)}"
    end

    def items_for_category(category)
      tonic_collection.select { |item| item.category == category }
    end

    def render_tags(tags)
      return if !tags

      tags.sort.map do |tag|
        "<span class='tag'>#{tag}</span>"
      end.join(" ")
    end

    def render_hash(hash)
      hash.map do |k, v|
        if is_hash?(v)
          render_hash(v)
        else
          "#{k.titleize}: #{v}"
        end
      end.join(" | ")
    end

    def render_video(video_url)
      embed_url = VideoInfo.new(video_url).embed_url

      "<iframe class='w-full aspect-video' src='#{embed_url}' allowfullscreen></iframe>"
    end

    def render_audio(audio_url)
      "<audio controls src='#{audio_url}'></audio>"
    end

    def strip_truncate(html, length)
      truncate(strip_tags(html), length: length)
    end

    def single_word?(string)
      !string.strip.include? " "
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
      string.match?(URI.regexp)
    end

    def is_email?(string)
      string.match?(URI::MailTo::EMAIL_REGEXP)
    end

    def is_hash?(object)
      object.class.name.end_with?("Hash")
    end

    def is_video?(string)
      VideoInfo.valid_url?(string)
    end

    def is_audio?(string)
      string.match?(/\.(mp3|ogg|wav)$/)
    end

    # Statistics methods for the insights page
    def collection_stats
      collection = tonic_collection  # Get collection once
      {
        total_items: collection.size,
        unique_fields: collection_fields.size,
        fields_by_type: analyze_field_types
      }
    end

    def collection_fields
      @collection_fields ||= tonic_collection.flat_map(&:keys).uniq.sort - Tonic::MAGIC_ATTRS
    end

    def analyze_field_types
      fields = {}
      collection_fields.each do |field|
        fields[field] = infer_field_type_for_stats(field)
      end
      fields
    end

    def infer_field_type_for_stats(field)
      begin
        collection = tonic_collection  # Get collection once
        sample_values = collection.map { |item| item[field] }.compact.first(10)
        return 'empty' if sample_values.empty?
        
        first_value = sample_values.first
        return 'empty' if first_value.nil?
        
        # Check for arrays (tags)
        if first_value.is_a?(Array)
          return 'tags'
        end
        
        # Check for boolean
        if is_bool?(first_value)
          return 'boolean'
        end
        
        # Check for numeric
        if first_value.is_a?(Numeric)
          return 'numeric'
        end
        
        # Check for dates
        if first_value.is_a?(String) && (field.end_with?('_at') || is_date?(first_value))
          return 'date'
        end
        
        # Check if it's categorical (limited unique values)
        # Only check unique values if we need to determine categorical vs text
        unique_sample_values = sample_values.uniq
        if unique_sample_values.size <= 10 && unique_sample_values.size > 1
          # Do a more thorough check for categorical by looking at all values
          all_values = fetch_values(field)
          unique_values = all_values.uniq
          if unique_values.size <= 10 && unique_values.size > 1
            return 'categorical'
          end
        end
        
        # Default to text
        'text'
      rescue
        'empty'
      end
    end

    def field_statistics(field, type = nil)
      collection = tonic_collection  # Get collection once
      type ||= infer_field_type_for_stats(field)
      values = fetch_values(field)
      
      stats = {
        field: field,
        type: type,
        total_items: collection.size,
        non_empty_items: collection.count { |item| 
          value = item[field]
          !value.nil? && value != '' 
        }
      }
      
      case type
      when 'numeric'
        stats.merge!(numeric_field_stats(field, values))
      when 'categorical'
        stats.merge!(categorical_field_stats(field, values))
      when 'tags'
        stats.merge!(tags_field_stats(field))
      when 'date'
        stats.merge!(date_field_stats(field, values))
      when 'boolean'
        stats.merge!(boolean_field_stats(field))
      else
        stats.merge!(text_field_stats(field, values))
      end
      
      stats
    end

    def numeric_field_stats(field, values)
      return {
        min: 0,
        max: 0,
        avg: 0,
        median: 0
      } if values.empty?
      
      numeric_values = values.map(&:to_f)
      return {
        min: 0,
        max: 0,
        avg: 0,
        median: 0
      } if numeric_values.empty?
      
      sorted_values = numeric_values.sort
      {
        min: numeric_values.min,
        max: numeric_values.max,
        avg: (numeric_values.sum / numeric_values.size.to_f).round(2),
        median: sorted_values[sorted_values.size / 2]
      }
    end

    def categorical_field_stats(field, values)
      value_counts = values.group_by(&:itself).transform_values(&:size)
      {
        unique_values: values.uniq.size,
        most_common: value_counts.sort_by { |k, v| -v }.first(5),
        value_distribution: value_counts
      }
    end

    def tags_field_stats(field)
      collection = tonic_collection  # Get collection once
      all_tags = collection.flat_map { |item| 
        value = item[field]
        value || [] 
      }
      tag_counts = all_tags.group_by(&:itself).transform_values(&:size)
      {
        total_tags: all_tags.size,
        unique_tags: tag_counts.keys.size,
        most_common_tags: tag_counts.sort_by { |k, v| -v }.first(10),
        tag_distribution: tag_counts
      }
    end

    def date_field_stats(field, values)
      return { date_values: 0 } if values.empty?
      
      date_values = values.map { |v| Date.parse(v.to_s) rescue nil }.compact
      return { date_values: 0 } if date_values.empty?
      
      {
        earliest: date_values.min,
        latest: date_values.max,
        date_range_days: (date_values.max - date_values.min).to_i,
        dates_by_year: date_values.group_by(&:year).transform_values(&:size)
      }
    end

    def boolean_field_stats(field)
      collection = tonic_collection  # Get collection once
      values = collection.map { |item| 
        value = item[field]
        value
      }.compact
      true_count = values.count(true)
      false_count = values.count(false)
      {
        true_count: true_count,
        false_count: false_count,
        true_percentage: values.size > 0 ? (true_count.to_f / values.size * 100).round(1) : 0
      }
    end

    def text_field_stats(field, values)
      return {
        unique_values: 0,
        avg_length: 0,
        most_common: []
      } if values.empty?
      
      {
        unique_values: values.uniq.size,
        avg_length: values.map(&:to_s).map(&:length).sum.to_f / values.size,
        most_common: values.group_by(&:itself).transform_values(&:size).sort_by { |k, v| -v }.first(5)
      }
    end

    def fetch_values(field)
      @fetch_values_cache ||= {}
      @fetch_values_cache[field] ||= tonic_collection.map { |item| item[field] }.compact.reject { |v| v == '' }
    end

    private

    def validate_item!(item)
      if item.name.blank?
        raise "[Tonic] Name can't be blank:\n#{item.to_h}\n"
      end

      if data.collection.count { |el| el.name == item.name } > 1
        raise "[Tonic] Name should be unique:\n#{item.to_h}\n"
      end
    end
  end
end
