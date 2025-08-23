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
      stats = {}

      all_attributes_names.each do |field|
        next if Tonic::SKIP_FOR_FILTERS.include?(field)

        values = fetch_values(field)
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

    def frequency_analysis(values, limit)
      values.each_with_object({}) { |value, hash| hash[value] += 1 }
            .sort_by { |_, count| -count }
            .first(limit)
            .to_h
    end
  end
end
