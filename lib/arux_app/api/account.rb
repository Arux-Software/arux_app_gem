module AruxApp
  module API
    class Account
      attr_accessor :auth, :access_token, :api_version

      def initialize(options = {})
        self.auth         = options[:auth]
        self.access_token = options[:access_token]
        self.api_version  = options[:api_version] || 1.3

        raise API::InitializerError.new(:auth_or_access_token, "can't be blank") if self.auth.nil? and self.access_token.nil?
        raise API::InitializerError.new(:auth, "must be of class type AruxApp::API::Auth") if self.auth and !self.auth.is_a?(AruxApp::API::Auth)
        raise API::InitializerError.new(:access_token, "must be of class type AruxApp::API::Auth::AccessToken") if self.access_token and !self.access_token.is_a?(AruxApp::API::Auth::AccessToken)
      end

      def self.public_uri
        AruxApp::API.uri(subdomain: "account")
      end

      def public_uri
        self.class.public_uri
      end

      def self.api_uri
        AruxApp::API.uri(subdomain: "account.api")
      end

      def api_uri
        self.class.api_uri
      end

      def list(params = {})
        request = HTTPI::Request.new
        request.url = "#{api_route}/users"
        request.query = URI.encode_www_form(params)
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def get(uuid, params = {})
        uuid = AruxApp::API.uri_escape(uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}"
        request.query = URI.encode_www_form(params)
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def create(params)
        request = HTTPI::Request.new
        request.url = "#{api_route}/users/"
        request.body = params.to_json
        request.headers = self.generate_headers

        response = HTTPI.post(request)

        if response.code == 201
          true
        elsif !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def update(uuid, params)
        uuid = AruxApp::API.uri_escape(uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}"
        request.body = params.to_json
        request.headers = self.generate_headers

        response = HTTPI.put(request)

        if response.code == 204
          true
        elsif !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def merge(uuid1, uuid2)
        uuid1 = AruxApp::API.uri_escape(uuid1)
        uuid2 = AruxApp::API.uri_escape(uuid2)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/merge/#{uuid1}/#{uuid2}"
        request.headers = self.generate_headers

        response = HTTPI.put(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def delete(uuid)
        uuid = AruxApp::API.uri_escape(uuid.to_s)

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/#{uuid}"
        request.headers = self.generate_headers

        response = HTTPI.delete(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      def owner(params = {})
        raise API::RequirementError.new(:access_token, "can't be blank") if self.access_token.nil?

        request = HTTPI::Request.new
        request.url = "#{api_route}/users/owner"
        request.query = URI.encode_www_form(params)
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

      # TODO:: create mapping for relationships api endpoints
      def list_relationships
      end

      def add_relationship
      end

      def update_relationship
      end

      def delete_relationship
      end

      protected

      def api_route
        "#{api_uri}/api/v#{api_version}"
      end

      def generate_headers
        if self.access_token
          {'User-Agent' => USER_AGENT, 'Authorization' => self.access_token.token, 'Content-Type' => "application/json"}
        else
          {'User-Agent' => USER_AGENT, 'Client-Secret' => self.auth.client_secret, 'Client-Id' => self.auth.client_id, 'Content-Type' => "application/json"}
        end
      end

    end
  end
end
