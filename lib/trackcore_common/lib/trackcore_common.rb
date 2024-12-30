require 'jwt'
require 'oj'
require 'request_store'

module TrackcoreCommon
  class Error < StandardError; end
  
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config) if block_given?
  end
end

require_relative 'trackcore_common/configuration'
require_relative 'trackcore_common/auth'
require_relative 'trackcore_common/json_logger'
require_relative 'trackcore_common/middleware'
