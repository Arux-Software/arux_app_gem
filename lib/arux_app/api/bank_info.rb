module AruxApp
  module API
    class BankInfo
      def self.public_uri
        AruxApp::API.uri(subdomain: "banks")
      end

      def self.api_uri
        AruxApp::API.uri(subdomain: "banks.api")
      end

      def get(routing_number)
        routing_number = AruxApp::API.uri_escape(routing_number.to_s)

        request = HTTPI::Request.new
        request.url = "#{self.class.server_uri}/#{routing_number}"
        request.headers = {'User-Agent' => USER_AGENT}

        response = HTTPI.get(request)

        if !response.error?
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.code, response.body))
        end
      end

    end
  end
end
