module TrackcoreCommon
  class JsonLogger
    def self.setup
      logger = Logger.new(TrackcoreCommon.config.log_path)
      logger.formatter = proc do |severity, datetime, progname, msg|
        Oj.dump({
          timestamp: datetime.iso8601,
          severity: severity,
          message: msg,
          request_id: RequestStore.store[:request_id]
        }) + "\n"
      end
      logger
    end
  end
end
