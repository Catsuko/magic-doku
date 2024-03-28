module Generation
  class Puzzle

    def initialize(size:, card_power_map: {})
      @size = size
      @card_power_map = card_power_map
    end

    def add_card(id:, power:)
      @card_power_map.store(power, id) unless @card_power_map.key?(power)
    end

    def full?
      @card_power_map.size == @size
    end

    def clear
      @card_power_map.clear
    end

    def save_to(repository, seed:)
      repository.store(seed, card_ids: @card_power_map.values)
    end
  end
end
