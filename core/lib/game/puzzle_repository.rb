require 'digest'

module Game
  class PuzzleRepository

    def initialize(storage:, library:)
      @storage = storage
      @library = library
    end

    def find(seed, maximum_tries: 3)
      card_ids = @storage.fetch(seed)
      raise "Could not find puzzle for #{seed}" unless card_ids

      cards = CardSequence.new(@library.fetch(card_ids))
      Puzzle.new(cards, seed: seed, maximum_tries: maximum_tries)
    end

    def store(seed, card_ids:)
      card_ids = card_ids.shuffle(random: Random.new(seed))
      @storage.save(seed, unique_key: card_digest(card_ids), value: card_ids)      
    end

    private

    def card_digest(card_ids)
      digest = Digest::MD5.new
      digest.hexdigest(card_ids.sort.join('').hash.to_s)
    end
  end
end
