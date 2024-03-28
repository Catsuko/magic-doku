module Game
  class Attempt
    def initialize(cards, tries: 0, maximum_tries: 3)
      @cards = cards
      @tries = tries
      @maximum_tries = maximum_tries
    end

    def tries_remaining
      @maximum_tries - @tries
    end

    def correct?(puzzle, &block)
      if fresh?
        puzzle.starting_cards.compare(@cards, &block)
      else
        @cards.compare(puzzle.solution, &block)
      end
    end

    def try(cards)
      valid_try = can_try_again? && cards != @cards
      return unless valid_try

      @cards = cards
      @tries += 1
      valid_try
    end

    def to_h
      { tries: @tries, card_ids: @cards.map { |card| card.fetch(:id) } }
    end

    def save_to(attempt_storage)
      attempt_storage.save(tries: @tries, card_ids: @cards.map { |card| card.fetch(:id) })
    end

    def self.fresh
      Attempt.new(CardSequence.none)
    end

    private

    def fresh?
      @tries.zero?
    end

    def can_try_again?
      @tries < @maximum_tries
    end
  end
end
