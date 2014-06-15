require "json"
require "deployd/version"
require "deployd/capistrano"
require "deployd/config"
require 'parse-ruby-client'
require 'bitbucket_rest_api'

module Deployd
	require "deployd/railtie.rb" if defined?(Rails)

	@config = Deployd::Config.new

	def self.config

		if block_given?
			yield(@config)
		else
			@config
		end

	end
end
