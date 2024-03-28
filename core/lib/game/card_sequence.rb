module Game
  class CardSequence
    include Enumerable

    def initialize(cards)
      @cards = cards
    end

    def each(&block)
      @cards.each(&block)
    end

    def match(ids)
      CardSequence.new(ids.map { |id| fetch(id) })
    end

    def fetch(id)
      index = @cards.index { |card| card.fetch(:id) == id }
      raise 'Could not fetch card ##{id}' if index.nil?

      @cards[index]
    end

    def compare(sequence)
      each_with_index.reduce(true) do |same_order, (card, i)|
        card_in_place = sequence.has?(card, at: i)
        yield(card, card_in_place) if block_given?
        same_order && card_in_place
      end
    end

    def has?(expected_card, at:)
      actual_card = @cards[at]
      actual_card && actual_card.fetch(:id) == expected_card.fetch(:id)    
    end

    def ==(sequence)
      sequence.is_a?(self.class) && count == sequence.count && compare(sequence)
    end

    def self.none
      CardSequence.new([])
    end
  end
end
