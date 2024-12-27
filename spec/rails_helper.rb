# spec/rails_helper.rb

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

# If you’re using ActiveRecord, this ensures all migrations are up-to-date:
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => err
  abort err.to_s.strip
end

RSpec.configure do |config|
  # If you want to load custom support files (e.g. in spec/support/**),
  # you can uncomment/modify the line below:
  #
  # Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

  # Where to look for fixture files (if using fixtures).
  config.fixture_paths = [Rails.root.join('spec', 'fixtures')]

  # Use transactional fixtures if you’re using ActiveRecord.
  config.use_transactional_fixtures = true

  # You can configure RSpec to automatically tag specs by their directory.
  # e.g. spec/models => type: :model
  # Uncomment if desired:
  # config.infer_spec_type_from_file_location!

  # Filter out Rails gems from the backtrace in failures:
  config.filter_rails_from_backtrace!
end
