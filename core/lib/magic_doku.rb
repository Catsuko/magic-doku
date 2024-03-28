require 'yaml'
require_relative 'library/json_dump'
require_relative 'generation/puzzle_factory'
require_relative 'game/puzzle'
require_relative 'game/puzzle_repository'
require_relative 'game/card_sequence'
require_relative 'game/attempt'

module MagicDoku
  def self.library
    data_path = File.join(__dir__, '..', 'data', 'cards.json')
    config_path = File.join(__dir__, '..', 'config', 'power_ranking.yml')
    Library::JSONDump.new(data_path, config: YAML.load(File.read(config_path)))
  end

  def self.generate_puzzle(seed, size:, save_to:)
    Generation::PuzzleFactory.new(library: library, size: size).create_for(seed, repository: save_to)
  end

  def self.puzzle_repository(storage:)
    Game::PuzzleRepository.new(storage: storage, library: library)
  end
end
