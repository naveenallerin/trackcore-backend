Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq::Cron::Job.create(
      name: 'Job Board Distribution - Daily',
      cron: '0 0 * * *',  # Run at midnight daily
      class: 'JobBoardDistributionJob'
    )
  end
end
