module TrackcoreCommon
  class AuthMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      return unauthorized unless auth_header = env['HTTP_AUTHORIZATION']
      
      token = auth_header.split(' ').last
      begin
        payload = Auth.verify_token(token)
        RequestStore.store[:current_user] = payload.first['sub']
        @app.call(env)
      rescue Auth::TokenError
        unauthorized
      end
    end

    private

    def unauthorized
      [401, {'Content-Type' => 'application/json'}, 
       [Oj.dump({ error: 'Unauthorized' })]]
    end
  end
end
