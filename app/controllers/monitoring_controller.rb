class MonitoringController < ApplicationController
  skip_before_action :verify_authenticity_token

  def health
    render json: {
      status: 'ok',
      timestamp: Time.current,
      database: check_database,
      redis: check_redis,
      memory_mb: `ps -o rss= -p #{Process.pid}`.to_i / 1024,
      ruby_version: RUBY_VERSION,
      rails_version: Rails.version,
      environment: Rails.env
    }
  end

  def metrics
    render json: {
      database: {
        pool_size: ActiveRecord::Base.connection_pool.size,
        active_connections: ActiveRecord::Base.connection_pool.connections.length
      },
      redis: {
        connected: Redis.current.connected?
      },
      process: {
        memory_mb: `ps -o rss= -p #{Process.pid}`.to_i / 1024,
        cpu_usage: `ps -o %cpu= -p #{Process.pid}`.to_f
      }
    }
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute('SELECT 1')
    { connected: true }
  rescue StandardError => e
    { connected: false, error: e.message }
  end

  def check_redis
    Redis.current.ping == 'PONG' ? { connected: true } : { connected: false }
  rescue StandardError => e
    { connected: false, error: e.message }
  end
end