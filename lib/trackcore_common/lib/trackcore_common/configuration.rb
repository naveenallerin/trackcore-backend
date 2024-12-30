module TrackcoreCommon
  class Configuration
    attr_accessor :jwt_secret, :jwt_algorithm, :log_path

    def initialize
      @jwt_secret = ENV['JWT_SECRET']
      @jwt_algorithm = 'HS256'
      @log_path = 'log/application.json.log'
    end
  end
end
