module AruxApp
  module API
    class BankInfo
      def self.public_uri
        AruxApp::API.uri(subdomain: "banks")
      end

      def public_uri
        self.class.public_uri
      end

      def self.api_uri
        AruxApp::API.uri(subdomain: "banks.api")
      end

      def api_uri
        self.class.api_uri
      end

      def self.connection
        AruxApp::API.connection(uri: api_uri)
      end

      def connection
        self.class.connection
      end

      def get(routing_number)
        routing_number = AruxApp::API.uri_escape(routing_number.to_s)
        conn = connection
        response = conn.get("/#{routing_number}")
        if response.status < 400
          JSON.parse(response.body)
        else
          raise(API::Error.new(response.status, response.body))
        end
      end

    end
  end
end
