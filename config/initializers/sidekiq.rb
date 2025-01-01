Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq::Cron::Job.create(
      name: 'Job Board Distribution - Daily',
      cron: '0 0 * * *',  # Run at midnight daily
      class: 'JobBoardDistributionJob'
    )
    Sidekiq::Cron::Job.create(
      name: 'Approval Escalation Check',
      cron: '*/30 * * * *', # Every 30 minutes
      class: 'ApprovalEscalationJob'
    )
  end
end
