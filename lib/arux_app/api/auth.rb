module AruxApp
  module API
    class Auth
      class InvalidGrantError < API::Error; end
      class InvalidClientError < API::Error; end

      class AccessToken
        attr_accessor :token, :auth, :scope

        def initialize(options = {})
          self.token = options[:token]
          self.auth = options[:auth]
          self.scope = options[:scope]

          raise API::InitializerError.new(:token, "can't be blank") if self.token.to_s.empty?
          raise API::InitializerError.new(:auth, "can't be blank") if self.auth.nil?
          raise API::InitializerError.new(:auth, "must be of class type AruxApp::API::Auth") if !self.auth.is_a?(AruxApp::API::Auth)
        end

        def user_data(params = {})
          if @user_data.nil? and !@token.nil?
            acc = AruxApp::API::Account.new(:access_token => self)
            @user_data = acc.owner(params)["user"]
          end
          @user_data
        end
      end

      def self.server_uri
        AruxApp::API.server_uri
      end

      attr_accessor :client_id, :client_secret, :redirect_uri, :js_callback, :district_subdomain, :current_user_uuid, :login_mechanism, :element

      def initialize(options = {})
        self.client_id = options[:client_id]
        self.client_secret = options[:client_secret]
        self.redirect_uri = options[:redirect_uri]
        self.js_callback = options[:js_callback]
        self.login_mechanism = options[:login_mechanism] || 'redirect'
        self.element = options[:element]
        self.district_subdomain = options[:district_subdomain]
        self.current_user_uuid = options[:current_user_uuid]

        raise API::InitializerError.new(:client_id, "can't be blank") if self.client_id.to_s.empty?
        raise API::InitializerError.new(:client_secret, "can't be blank") if self.client_secret.to_s.empty?
        raise API::InitializerError.new(:redirect_uri, "can't be blank") if self.redirect_uri.to_s.empty?
      end

      def authorization_url(scope: "public")
        base_uri = URI.parse("#{self.class.server_uri}/oauth/authorize")
        params = {
          scope: scope,
          response_type: "code",
          client_id: client_id,
          redirect_uri: redirect_uri,
          district: district_subdomain
        }
        base_uri.query = URI.encode_www_form(params)
        base_uri.to_s
      end

      def basic_authentication(username, password, scope = "public")
        params = {
          scope: scope,
          grant_type: "password",
          client_id: client_id,
          client_secret: client_secret
        }

        request = HTTPI::Request.new.tap do |req|
          req.url = "#{self.class.server_uri}/oauth/token"
          req.body = params
          req.headers = { 'User-Agent' => USER_AGENT }
          req.auth.basic(username, password)
        end

        response = HTTPI.post(request)
        raise(API::Error.new(response.code, response.body)) if response.error?

        AccessToken.new(
          token: JSON.parse(response.body)['access_token'],
          scope: JSON.parse(response.body)['scope'],
          auth: self
        )
      end


      def registration_url
        %(#{self.class.server_uri}/users/registrations?client_id=#{self.client_id}&redirect_uri=#{self.redirect_uri}&district=#{self.district_subdomain})
      end

      def access_token(code)
        data = {
          :code => code,
          :grant_type => "authorization_code",
          :redirect_uri => self.redirect_uri,
          :client_secret => self.client_secret,
          :client_id => self.client_id
        }

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}/oauth/token"
        request.body = data
        request.headers = {'User-Agent' => USER_AGENT}

        response = HTTPI.post(request)

        if !response.error?
          AccessToken.new(
            token: JSON.parse(response.body)['access_token'],
            scope: JSON.parse(response.body)['scope'],
            auth: self
          )
        else
          begin
            resp_data = JSON.parse(response.body)
          rescue
          end
          if resp_data and resp_data["error"] == "invalid_grant"
            raise(API::Auth::InvalidGrantError.new(response.code, response.body))
          elsif resp_data and resp_data["error"] == "invalid_client"
            raise(API::Auth::InvalidClientError.new(response.code, response.body))
          else
            raise(API::Error.new(response.code, response.body))
          end
        end
      end

      def client_credentials_token
        data = {
          scope: "public",
          grant_type: "client_credentials",
          client_id: client_id,
          client_secret: client_secret
        }

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}/oauth/token"
        request.body = data
        request.headers = {'User-Agent' => USER_AGENT}

        response = HTTPI.post(request)
        if !response.error?
          AccessToken.new(:token => JSON.parse(response.body)['access_token'], auth: self)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def javascript
        options = {
          district: self.district_subdomain,
          element: self.element,
          login: {
            current_uuid: self.current_user_uuid,
            client_id: self.client_id,
            redirect_uri: self.redirect_uri,
            login_mechanism: self.login_mechanism,
            callback: self.js_callback
          }
        }
        return %(new SwitchBoardIOLogin(#{options.to_json});)
      end

    end
  end
end
