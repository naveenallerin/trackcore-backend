module TrackcoreCommon
  module Auth
    class TokenError < StandardError; end

    def self.verify_token(token)
      JWT.decode(token, TrackcoreCommon.config.jwt_secret, 
                true, algorithm: TrackcoreCommon.config.jwt_algorithm)
    rescue JWT::DecodeError => e
      raise TokenError, "Invalid token: #{e.message}"
    end

    def self.generate_token(payload)
      JWT.encode(payload, TrackcoreCommon.config.jwt_secret, 
                TrackcoreCommon.config.jwt_algorithm)
    end
  end
end
