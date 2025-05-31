# This file is copied to spec/ when you run "rails generate rspec:install"
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

# Carrega todos os arquivos de suporte (como support/factory_bot.rb, custom matchers, etc)
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Usa fixtures se estiverem definidas
  config.fixture_paths = [Rails.root.join("spec/fixtures")]

  # Envolve cada teste em uma transação de banco (útil para rollback automático)
  config.use_transactional_fixtures = true

  # Habilita métodos como `create`, `build`, etc. diretamente nos testes
  config.include FactoryBot::Syntax::Methods

  # Inferência automática de tipo com base no caminho (ex: spec/models => type: :model)
  config.infer_spec_type_from_file_location!

  # Limpa os backtraces do Rails para facilitar a leitura
  config.filter_rails_from_backtrace!
  config.backtrace_exclusion_patterns << /gems/

  config.before(:each) do
    # Define o host para gerar URLs nos testes (necessário para Devise)
    default_url_options = {host: "http://localhost", port: 3000}
    allow(Rails.application.routes).to receive(:default_url_options).and_return(default_url_options)
  end
end
