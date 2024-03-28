module Game
  class Puzzle
    attr_reader :seed

    def initialize(cards, seed:, maximum_tries: 3)
      @cards = cards
      @seed = seed
      @maximum_tries = maximum_tries
    end

    def starting_cards
      @cards
    end

    def solution
      CardSequence.new(@cards.sort_by { |card| card.fetch(:power) })
    end

    def attempt(card_ids, tries:)
      Attempt.new(cards_matching(card_ids), tries: tries, maximum_tries: @maximum_tries)
    end

    def cards_matching(card_ids)
      @cards.match(card_ids)
    end
  end
end
