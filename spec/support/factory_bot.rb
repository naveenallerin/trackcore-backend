RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# Ensure factories are loaded
FactoryBot.find_definitions rescue nil
