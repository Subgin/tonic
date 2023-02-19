module Tonic
  module Utils
    extend self

    def slugify(text)
      text&.parameterize
    end

    def strip_truncate(html, length)
      truncate(strip_tags(html), length: length)
    end

    def single_word?(string)
      !string.strip.include? " "
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
      string.match?(/youtube\.com|youtu\.be|vimeo\.com|dailymotion\.com/)
    end

    def is_audio?(string)
      string.match?(/\.(mp3|ogg|wav)$/)
    end
  end
end
