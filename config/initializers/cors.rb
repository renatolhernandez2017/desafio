Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:5173' # ou o domínio do seu frontend

    resource '*',
      headers: :any,
      expose: ['Authorization'],
      methods: [:get, :post, :options]
  end
end
