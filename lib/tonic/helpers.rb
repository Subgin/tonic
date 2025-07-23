module Tonic
  module Helpers
    extend self

    def config
      data.config.reverse_merge(
        title: "Tonic Example",
        detail_pages: true,
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
