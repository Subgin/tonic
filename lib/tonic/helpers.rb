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

    def slugify(text)
      text&.parameterize
    end

    # Simple, safe collection access that doesn't trigger infinite loops
    def tonic_collection
      @tonic_collection ||= begin
        collection = []
        data.collection.each do |item|
          # Create a simple hash copy to avoid modifying the original
          item_hash = {}
          item.each_pair { |k, v| item_hash[k] = v }
          item_hash[:id] = slugify(item_hash[:name])
          item_hash[:dom_id] = "item_#{item_hash[:id]}"
          collection << OpenStruct.new(item_hash)
        end
        collection
      end
    rescue
      []
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
      return [] if tonic_collection.empty?
      
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
  end
end
