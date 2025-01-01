Rails.application.configure do
  config.middleware.use RequestStore::Middleware
  config.middleware.insert_after RequestStore::Middleware, Rack::RequestId
end
