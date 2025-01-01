require 'rails_helper'

RSpec.describe KnockoutEngineService do
  let(:service) { described_class.new }

  describe '#evaluate_candidate' do
    let(:candidate) { create(:candidate) }

    context 'with experience rules' do
      let!(:rule) do
        create(:knockout_rule,
          name: 'Minimum Experience',
          rule_expression: {
            type: 'experience',
            condition: {
              operator: '>=',
              value: 5
            }
          }
        )
      end

      it 'fails candidates with insufficient experience' do
        create(:work_experience, 
          candidate: candidate,
          start_date: 2.years.ago,
          end_date: Date.current
        )

        result = service.evaluate_candidate(candidate)
        expect(result).not_to be_passed
        expect(result.failed_rules.first[:name]).to eq('Minimum Experience')
      end

      it 'passes candidates with sufficient experience' do
        create(:work_experience,
          candidate: candidate,
          start_date: 6.years.ago,
          end_date: Date.current
        )

        result = service.evaluate_candidate(candidate)
        expect(result).to be_passed
      end
    end

    context 'with skills rules' do
      let!(:rule) do
        create(:knockout_rule,
          name: 'Required Skills',
          rule_expression: {
            type: 'skills',
            condition: {
              operator: 'includes_all',
              value: ['Ruby', 'Rails']
            }
          }
        )
      end

      it 'fails candidates missing required skills' do
        candidate.skills = [create(:skill, name: 'Ruby')]
        
        result = service.evaluate_candidate(candidate)
        expect(result).not_to be_passed
      end

      it 'passes candidates with all required skills' do
        candidate.skills = [
          create(:skill, name: 'Ruby'),
          create(:skill, name: 'Rails')
        ]
        
        result = service.evaluate_candidate(candidate)
        expect(result).to be_passed
      end
    end
  end

  describe '#evaluate_multiple' do
    let(:candidates) { create_list(:candidate, 3) }
    
    it 'returns results for all candidates' do
      results = service.evaluate_multiple(candidates)
      expect(results.keys).to match_array(candidates.map(&:id))
    end
  end
end
