require 'rails_helper'

RSpec.describe TemplateRendererService do
  describe '.render_content' do
    it 'replaces matching placeholders' do
      body = "Hello {{NAME}}"
      placeholders = { "NAME" => "Alice" }
      
      result = described_class.render_content(body, placeholders)
      expect(result).to eq("Hello Alice")
    end

    it 'ignores placeholders that do not appear' do
      body = "Hello {{NAME}}"
      placeholders = { "NAME" => "Alice", "AGE" => "25" }
      
      result = described_class.render_content(body, placeholders)
      expect(result).to eq("Hello Alice")
    end

    it 'handles multiple different placeholders' do
      body = "{{NAME}} is {{AGE}} years old"
      placeholders = { "NAME" => "Alice", "AGE" => "25" }
      
      result = described_class.render_content(body, placeholders)
      expect(result).to eq("Alice is 25 years old")
    end

    it 'handles repeated placeholders' do
      body = "{{NAME}} and {{NAME}} are friends"
      placeholders = { "NAME" => "Alice" }
      
      result = described_class.render_content(body, placeholders)
      expect(result).to eq("Alice and Alice are friends")
    end

    it 'returns original string when no placeholders provided' do
      body = "Hello {{NAME}}"
      
      result = described_class.render_content(body)
      expect(result).to eq("Hello {{NAME}}")
    end
  end
end
