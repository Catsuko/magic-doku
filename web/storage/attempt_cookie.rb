require 'json'

module Storage
  class AttemptCookie
    def initialize(path:, ttl:)
      @path = path
      @ttl = ttl
    end

    def save(attempt, puzzle:, response:)
      response.set_cookie(
        key_for(puzzle),
        value:   JSON.dump(attempt.to_h),
        expires: expires_in,
        path: @path.sub(/:seed/, key_for(puzzle))
      )
    end

    def load(puzzle, cookies:)
      attempt_details = JSON.parse(cookies[key_for(puzzle)] || '{}')
      puzzle.attempt(attempt_details.fetch('card_ids', []), tries: attempt_details.fetch('tries', 0))
    end

    private

    def key_for(puzzle)
      puzzle.seed.to_s
    end

    def expires_in
      Time.now + @ttl
    end

  end
end
