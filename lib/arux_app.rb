require 'rubygems'
require 'httpi'
require 'json'

require "arux_app/api"

require "arux_app/api/bank_info"
require "arux_app/api/config"
require "arux_app/api/auth"
require "arux_app/api/nav"
require "arux_app/api/account"
require "arux_app/api/student"
require "arux_app/api/cart"

module AruxApp
  VERSION = "2.0.0"
  USER_AGENT = "Arux.app GEM #{VERSION}"
end

if ENV['ARUX_APP_GEM_TEST_MODE'].to_s == "true"
  AruxApp::API.testmode = true
end

if ENV['ARUX_APP_GEM_DEV_MODE'].to_s == "true"
  AruxApp::API.devmode = true
end

if ENV.has_key?("DEV_HOST")
  HOSTNAME = ENV.fetch("DEV_HOST")
elsif RUBY_PLATFORM =~ /darwin/
  HOSTNAME = "#{`scutil --get LocalHostName`.downcase.strip}.local"
else
  HOSTNAME = `hostname`.downcase.strip
end
