module AruxApp
  module API
    class Checkout
      API_VERSION = 1

      def self.public_uri
        AruxApp::API.uri(subdomain: "pay")
      end

      def public_uri
        self.class.public_uri
      end

      def self.api_uri
        AruxApp::API.uri(subdomain: "pay.api")
      end

      def api_uri
        self.class.api_uri
      end

      def self.api_route
        "#{api_uri}/api/v#{API_VERSION}/"
      end

      def self.iframe_url
        case AruxApp::API.mode
        when :production
          "https://htp.tokenex.com/Iframe/Iframe-v3.min.js"
        when :staging, :development, :test
          "https://test-htp.tokenex.com/Iframe/Iframe-v3.min.js"
        else
          raise "AruxApp::API environment not supported"
        end
      end
    end
  end
end
