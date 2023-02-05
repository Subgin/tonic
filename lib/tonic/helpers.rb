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

      link_to "#{attribute.humanize} #{direction.upcase}", "#", onclick: "sortBy('#{option}')"
    end

    def sharing_platforms
      return Tonic::SHARING_PLATFORMS if !config.sharing_platforms

      Tonic::SHARING_PLATFORMS.select do |platform|
        config.sharing_platforms.include?(platform)
      end
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
