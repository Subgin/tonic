module Tonic
  module Helpers
    extend self

    def config
      data.config.reverse_merge(
        title: "Tonic Example",
        detail_pages: true,
        category_pages: true,
        stats_page: true,
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

    # Statistics and insights methods
    def collection_stats
      {
        total_items: tonic_collection.size,
        unique_fields: all_field_names.size,
        field_stats: generate_field_stats
      }
    end

    def all_field_names
      tonic_collection.flat_map(&:keys).uniq.sort
    end

    def generate_field_stats
      stats = {}
      
      all_field_names.each do |field|
        next if Tonic::SKIP_FOR_FILTERS.include?(field)
        next if config.filters&.exclude&.include?(field)
        
        values = tonic_collection.map { |item| item[field] }.compact
        next if values.empty?
        
        field_type = infer_field_type(field, values.first)
        stats[field] = {
          type: field_type,
          stats: calculate_field_stats(field, values, field_type)
        }
      end
      
      stats
    end

    def infer_field_type(field, sample_value)
      return 'array' if sample_value.is_a?(Array)
      return 'boolean' if is_bool?(sample_value)
      return 'hash' if is_hash?(sample_value)
      return 'numeric' if sample_value.is_a?(Numeric)
      
      if sample_value.is_a?(String)
        return 'date' if field.end_with?('_at') && is_date?(sample_value)
        return 'url' if is_url?(sample_value)
        return 'email' if is_email?(sample_value)
        return 'categorical' if field == 'category' || single_word?(sample_value)
      end
      
      'text'
    end

    def calculate_field_stats(field, values, field_type)
      stats = { total_entries: values.size }
      
      case field_type
      when 'array'
        all_array_values = values.flatten.compact
        stats.merge!(
          total_unique_values: all_array_values.uniq.size,
          most_common: frequency_analysis(all_array_values, 5),
          avg_items_per_entry: (all_array_values.size.to_f / values.size).round(2)
        )
      when 'categorical'
        stats.merge!(
          unique_values: values.uniq.size,
          most_common: frequency_analysis(values, 5)
        )
      when 'numeric'
        numeric_values = values.select { |v| v.is_a?(Numeric) }
        stats.merge!(
          min: numeric_values.min,
          max: numeric_values.max,
          average: (numeric_values.sum.to_f / numeric_values.size).round(2),
          unique_values: numeric_values.uniq.size
        )
      when 'date'
        date_values = values.map { |v| Date.parse(v.to_s) rescue nil }.compact
        stats.merge!(
          earliest: date_values.min,
          latest: date_values.max,
          unique_dates: date_values.uniq.size
        )
      when 'boolean'
        true_count = values.count(true)
        false_count = values.count(false)
        stats.merge!(
          true_count: true_count,
          false_count: false_count,
          true_percentage: (true_count.to_f / values.size * 100).round(1)
        )
      else
        stats.merge!(
          unique_values: values.uniq.size,
          most_common: frequency_analysis(values, 5)
        )
      end
      
      stats
    end

    def frequency_analysis(values, limit = 10)
      values.each_with_object(Hash.new(0)) { |value, hash| hash[value] += 1 }
           .sort_by { |_, count| -count }
           .first(limit)
           .to_h
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
