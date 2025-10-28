module AruxApp
  module API
    class SupportPortal
      DOMAINS = {
        production: "arux.blue",
        staging: "arux.blue",
        development: HOSTNAME,
        test: "arux.test"
      }

      def self.public_uri
        AruxApp::API.uri(subdomain: "support-portal")
      end

      def public_uri
        self.class.public_uri
      end

      def self.api_uri
        AruxApp::API.uri(subdomain: "support-portal.api")
      end

      def api_uri
        self.class.api_uri
      end
    end
  end
end
