require 'set'

module Storage
  class MemoryStore
    def initialize(unique_keys: Set.new, store: {})
      @unique_keys = unique_keys
      @store = store
    end

    def save(id, unique_key:, value:)
      @unique_keys.add?(unique_key).tap do |unique|
        @store.store(id, value)
      end
    end

    def fetch(id)
      @store.fetch(id)
    end
  end
end
