# frozen_string_literal: true

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/cookies'
require 'haml'
require 'magic_doku'
require 'byebug'

require_relative 'storage/memory_store'
require_relative 'storage/attempt_cookie'

configure do
  set :puzzle_size, 7
  set :puzzle_repository, MagicDoku.puzzle_repository(storage: Storage::MemoryStore.new)
  set :attempt_cookie, Storage::AttemptCookie.new(path: '/puzzles/:seed', ttl: 3600 * 24)
end

get '/' do
  redirect '/puzzles/random'
end

namespace '/puzzles' do
  get '/random' do
    seed = Time.now.to_i
    MagicDoku.generate_puzzle(seed, size: settings.puzzle_size, save_to: settings.puzzle_repository)
    redirect "/puzzles/#{seed}"
  end

  namespace '/:seed' do
    helpers do
      def puzzle
        settings.puzzle_repository.find(params.fetch(:seed).to_i)
      end
    end

    get do
      @puzzle = puzzle
      @attempt = settings.attempt_cookie.load(@puzzle, cookies: cookies)
      haml :puzzle
    end

    post do
      @puzzle = puzzle
      @attempt = settings.attempt_cookie.load(@puzzle, cookies: cookies)
      cards = @puzzle.cards_matching(params.fetch(:card_ids).map(&:to_i))

      settings.attempt_cookie.save(@attempt, puzzle: puzzle, response: response) if @attempt.try(cards)
      haml :puzzle
    end
  end
end
