require "json"
require "deployd/version"
require "deployd/capistrano"
require 'parse-ruby-client'
require 'bitbucket_rest_api'

module Deployd
	require "deployd/railtie.rb" if defined?(Rails)
end
