module AruxApp
  module API
    class Cart
      def self.server_uri
        if AruxApp::API.standardmode?
          "https://cart.arux.app"
        elsif AruxApp::API.testmode?
          "https://cart.arux.blue"
        elsif AruxApp::API.devmode?
          "https://cart.#{HOSTNAME}"
        end
      end

      attr_accessor :auth, :access_token

      def initialize(options = {})
        self.access_token = options[:access_token]
        self.auth = self.access_token.auth

        raise API::InitializerError.new(:access_token, "can't be blank") if self.access_token.nil?
        raise API::InitializerError.new(:access_token, "must be of class type AruxApp::API::Auth::AccessToken") if !self.access_token.is_a?(AruxApp::API::Auth::AccessToken)
      end

      def get(uuid = nil)
        if uuid
          path = %(/api/#{URI.escape(uuid)})
        else
          path = %(/api/#{self.generate_cart_path})
        end

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def get_status
        path = %(/api/#{self.generate_cart_path}/status)

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def get_items
        path = %(/api/#{self.generate_cart_path}/items)

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def get_item(item_identifier)
        path = %(/api/#{self.generate_cart_path}/items/#{item_identifier})

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        request.headers = self.generate_headers

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def add_item(params)
        path = %(/api/#{self.generate_cart_path}/items)

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        if params.keys.first.to_s != 'item'
          params = {:item => params}
        end
        request.body = params.to_json
        request.headers = self.generate_headers

        response = HTTPI.post(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def update_item(item_identifier, params)
        path = %(/api/#{self.generate_cart_path}/items/#{URI.escape(item_identifier)})

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        if params.keys.first.to_s != 'item'
          params = {:item => params}
        end
        request.body = params.to_json
        request.headers = self.generate_headers

        response = HTTPI.put(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def delete_item(item_identifier)
        path = %(/api/#{self.generate_cart_path}/items/#{URI.escape(item_identifier)})

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        request.headers = self.generate_headers

        response = HTTPI.delete(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def destroy(uuid)
        path = "/api/#{self.generate_cart_path}/carts/#{uuid}"
        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        request.headers = self.generate_headers

        response = HTTPI.delete(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      def create(params)
        path = "/api/#{self.generate_cart_path}/carts"
        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}#{path}"
        request.headers = self.generate_headers
        request.body = params.to_json

        response = HTTPI.post(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, JSON.parse(response.body)["message"]))
        end
      end

      protected

      def generate_cart_path
        %(#{URI.escape(self.auth.district_subdomain)}/#{URI.escape(self.access_token.token)})
      end

      def generate_headers
        {'User-Agent' => USER_AGENT, 'Client-Id' => self.auth.client_id, 'Content-Type' => 'application/json'}
      end
    end
  end
end
