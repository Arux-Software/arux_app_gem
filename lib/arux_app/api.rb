module AruxApp
  module API
    class << self
      @@mode = :standard
      [:test, :dev, :standard].each do |m|
        define_method("#{m}mode?") do
          @@mode == m
        end

        define_method("#{m}mode") do
          @@mode == m
        end

        define_method("#{m}mode=") do |b|
          @@mode = b ? m : :standard
        end
      end

      def server_uri
        if AruxApp::API.standardmode?
          "https://account.arux.app"
        elsif AruxApp::API.testmode?
          "https://account.arux.blue"
        elsif AruxApp::API.devmode?
          "https://account.#{HOSTNAME}"
        end
      end

      def uri_escape(str)
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
