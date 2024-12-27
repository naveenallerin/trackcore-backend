class RequestTimer
  def initialize(app)
    @app = app
  end

  def call(env)
    start_time = Time.current
    status, headers, response = @app.call(env)
    duration = Time.current - start_time

    Rails.logger.info(
      "Request completed | Duration: #{duration}s | Status: #{status} | Path: #{env['PATH_INFO']}"
    )

    [status, headers, response]
  end
end

Rails.application.config.version = begin
  File.read(Rails.root.join('VERSION')).strip
rescue
  '0.0.1'
end

Rails.application.config.middleware.use RequestTimer