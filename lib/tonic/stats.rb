module Tonic
  module Stats
    def collection_stats
      {
        total_items: tonic_collection.size,
        unique_fields: all_attributes_names.size,
        field_stats: generate_field_stats
      }
    end

    private

    def generate_field_stats
      @generate_field_stats ||= begin
        stats = {}

        all_attributes_names.each do |field|
          next if Tonic::SKIP_FOR_FILTERS.include?(field)

          values = cached_field_values(field, flatten: false, uniq: false)
          next if values.empty?

          field_type = infer_field_type(field, values.first)
          stats[field] = {
            type: field_type,
            stats: calculate_field_stats(field, values, field_type)
          }
        end

        stats
      end
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
        unique_array_values = all_array_values.uniq
        stats.merge!(
          total_unique_values: unique_array_values.size,
          most_common: frequency_analysis(all_array_values, 5),
          avg_items_per_entry: (all_array_values.size.to_f / values.size).round(1)
        )
      when 'categorical'
        unique_values = values.uniq
        stats.merge!(
          unique_values: unique_values.size,
          most_common: frequency_analysis(values, 5)
        )
      when 'numeric'
        numeric_values = values.select { |v| v.is_a?(Numeric) }
        unique_numeric_values = numeric_values.uniq
        stats.merge!(
          min: numeric_values.min,
          max: numeric_values.max,
          average: (numeric_values.sum.to_f / numeric_values.size).round(1),
          unique_values: unique_numeric_values.size
        )
      when 'date'
        date_values = parse_dates_cached(values)
        unique_date_values = date_values.uniq
        stats.merge!(
          earliest: date_values.min,
          latest: date_values.max,
          unique_dates: unique_date_values.size
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
        unique_values = values.uniq
        stats.merge!(
          unique_values: unique_values.size,
          most_common: frequency_analysis(values, 5)
        )
      end

      stats
    end

    def parse_dates_cached(values)
      @date_cache ||= {}
      values.map do |v|
        key = v.to_s
        @date_cache[key] ||= (Date.parse(key) rescue nil)
      end.compact
    end

    def frequency_analysis(values, limit)
      # Use tally for better performance if available (Ruby 2.7+), otherwise fallback
      if values.respond_to?(:tally)
        values.tally.sort_by { |_, count| -count }.first(limit).to_h
      else
        values.each_with_object(Hash.new(0)) { |value, hash| hash[value] += 1 }
              .sort_by { |_, count| -count }
              .first(limit)
              .to_h
      end
    end
  end
end
