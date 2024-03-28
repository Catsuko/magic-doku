require 'json'

module MagicDoku
  module Library
    class JSONDump

      include Enumerable

      def initialize(filename, config: {})
        @filename = filename
        @config = config
      end

      def each(&block)
        JSON.parse(File.read(@filename))
            .lazy
            .select { |c| eligible?(c) }
            .map { |c| map_fields(c) }
            .each(&block)
      end

      def fetch(card_ids)
        cards = card_ids.reduce([]) do |results, card_id|
          results << index.fetch(card_id.to_i).first
        end
      end

    private

      def index
        @index ||= group_by { |card_data| card_data[:id] }
      end

      def eligible?(card_details)
        includes_required_fields?(card_details) &&
        matches_expected_patterns?(card_details) &&
        no_excluded_terms?(card_details)
      end

      def includes_required_fields?(card_details)
        @required_fields ||= @config.fetch('includes') { [] }
        @required_fields.all? { |key| card_details[key] }
      end

      def matches_expected_patterns?(card_details)
        @expected_patterns ||= @config.fetch('matches') { {} }.transform_values { |v| Regexp.new(v) }
        @expected_patterns.all? { |key, pattern| card_details[key]&.match?(pattern) }
      end

      def no_excluded_terms?(card_details)
        @excluded_terms ||= @config.fetch('excludes') { {} }
        @excluded_terms.none? do |key, exclusion|
          case exclusion
          when Array
            exclusion.include?(card_details[key])
          else
            card_details[key]&.match?(Regexp.new(exclusion))
          end
        end
      end

      def map_fields(card_details, delimiter: '.')
        @mapping ||= @config.fetch('mapping') { {} }
        @mapping.reduce({}) do |mapped, (field, destination)|
          value = field.split(delimiter).reduce(card_details) do |fields, segment|
            fields&.fetch(segment, nil)
          end
          hash = destination.split(delimiter).reverse!.reduce({}) do |target, segment|
            target.empty? ? target.merge!(segment.to_sym => value) : { segment.to_sym => target }
          end
          mapped.merge!(hash)
        end
      end
    end
  end
end