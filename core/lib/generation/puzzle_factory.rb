require_relative 'puzzle'

module Generation
  class PuzzleFactory

    def initialize(library:, size:)
      @size = size
      @library = library
    end

    def create_for(seed, repository:)
      puzzle = Puzzle.new(size: @size)
      @library.to_a.shuffle(random: Random.new(seed)).each do |card|
        puzzle.add_card(**card.slice(:id, :power))
        next unless puzzle.full?

        if puzzle.save_to(repository, seed: seed)
          return true
        else
          puzzle.clear
        end
      end

      false
    end

  end
end
