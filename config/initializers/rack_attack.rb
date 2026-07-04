class Rack::Attack
  # In-memory store so throttle counters never hit Postgres/solid_cache (single web
  # process; counters are ephemeral by design).
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Generous for a personal app, but stops a hammering crawler cold. Skips static
  # assets and the healthcheck so neither can trip the limiter.
  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets", "/up")
  end
end
