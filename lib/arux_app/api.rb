module AruxApp
  module API
    DOMAINS = {
      production: "arux.app",
      staging: "arux.blue",
      development: HOSTNAME,
      test: "arux.test"
    }

    class << self
      def mode
        raise "Environment is not set, i.e. ARUX_APP_GEM_MODE = :development" unless const_defined?(:ARUX_APP_GEM_MODE)
        ARUX_APP_GEM_MODE
      end

      def uri(subdomain:)
        URI::HTTPS.build(
          host: [subdomain, domain].join('.'),
        )
      end

      def domain
        raise "#{mode} is not a supported environment" unless DOMAINS.has_key?(mode)
        DOMAINS[mode]
      end

      def uri_escape(str)
        # URI.escape was deprecated and removed in ruby
        # https://bugs.ruby-lang.org/issues/17309
        # The alternatives suggested were using URI::DEFAULT_PARSER
        # and CGI. This will use URI::DEFAULT_PARSER if it is defined and CGI
        # if not.
        if URI.respond_to?(:escape)
          URI.escape(str)
        elsif defined? URI::DEFAULT_PARSER
          URI::DEFAULT_PARSER.escape(str)
        else
          CGI.escape(str)
        end
      end
    end

    class Error < StandardError
      attr_accessor :http_status_code
      def initialize(code, message)
        self.http_status_code = code.to_i
        begin
          self.json = JSON.parse(message)
        rescue
        end

        super "(#{code}) #{message}"
      end
    end

    class InitializerError < StandardError
      def initialize(method, message)
        super "#{method} #{message}"
      end
    end

    class RequirementError < StandardError
      def initialize(method, message)
        super "#{method} #{message}"
      end
    end

  end
end
