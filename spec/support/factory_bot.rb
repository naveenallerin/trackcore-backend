RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    # Clear and reload factories
    FactoryBot.factories.clear
    FactoryBot.definition_file_paths = [
      Rails.root.join('spec', 'factories')
    ]
    FactoryBot.reload
  end
end
