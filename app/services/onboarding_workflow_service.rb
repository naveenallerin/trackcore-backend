class OnboardingWorkflowService
  DEFAULT_TASKS = [
    {
      title: 'Complete I-9 Form',
      description: 'Federal Employment Eligibility Verification',
      due_date_offset: 3,
      form_identifier: 'i9_form'
    },
    {
      title: 'Setup Direct Deposit',
      description: 'Add your bank account information',
      due_date_offset: 5,
      form_identifier: 'direct_deposit_form'
    },
    {
      title: 'Complete W-4',
      description: 'Federal Tax Withholding Form',
      due_date_offset: 3,
      form_identifier: 'w4_form'
    },
    {
      title: 'Schedule Orientation',
      description: 'Book your new hire orientation session',
      due_date_offset: 7
    }
  ].freeze

  def initialize(candidate)
    @candidate = candidate
    @hris = HrisAdapterService.new
  end

  def start_onboarding
    ActiveRecord::Base.transaction do
      create_onboarding_tasks
      sync_with_hris if hris_integration_enabled?
      notify_stakeholders
      
      { 
        status: 'success',
        tasks: @candidate.onboarding_tasks.reload,
        next_steps: next_steps
      }
    end
  rescue StandardError => e
    Rails.logger.error("Onboarding failed: #{e.message}")
    { status: 'error', message: e.message }
  end

  private

  def create_onboarding_tasks
    DEFAULT_TASKS.each do |task|
      @candidate.onboarding_tasks.create!(
        title: task[:title],
        description: task[:description],
        due_date: task[:due_date_offset].days.from_now,
        form_identifier: task[:form_identifier],
        status: 'pending'
      )
    end
  end

  def sync_with_hris
    response = @hris.create_employee(@candidate)
    @candidate.update!(
      hris_id: response.dig('data', 'employeeId'),
      hris_sync_status: 'synced'
    )
  end

  def notify_stakeholders
    OnboardingMailer.welcome_email(@candidate).deliver_later
    OnboardingMailer.notify_hr_team(@candidate).deliver_later
  end

  def next_steps
    {
      immediate_actions: @candidate.onboarding_tasks
        .where('due_date <= ?', 3.days.from_now)
        .pluck(:title),
      required_documents: ['Photo ID', 'Social Security Card', 'Bank Information'],
      orientation_info: 'HR will contact you to schedule orientation'
    }
  end

  def hris_integration_enabled?
    Rails.application.credentials.hris.present?
  end
end
