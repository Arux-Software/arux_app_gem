HOSTNAME = if ENV.has_key?("DEV_HOST")
             ENV.fetch("DEV_HOST")
           elsif RUBY_PLATFORM =~ /darwin/
             "#{`scutil --get LocalHostName`.downcase.strip}.local"
           else
             `hostname`.downcase.strip
           end

require 'rubygems'
require 'httpi'
require 'json'
require "arux_app/api"
require "arux_app/api/checkout"
require "arux_app/api/bank_info"
require "arux_app/api/config"
require "arux_app/api/auth"
require "arux_app/api/account"
require "arux_app/api/cart"

module AruxApp
  VERSION = "3.0.3"
  USER_AGENT = "Arux.app GEM #{VERSION}"
end
