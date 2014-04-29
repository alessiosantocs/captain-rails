require "json"
require "deployd/version"
require 'parse-ruby-client'
require 'bitbucket_rest_api'

module Deployd
	Parse.init :application_id => "RwigGFOvEjRsXUkKbmaLm1v4xqUozbx5XbQsLMib",
	           :api_key        => "be74IiB3Zlx93ATbhqzAApeVr1gOycDtHyu4jAk6"

	bitbucket = BitBucket.new do |config|
		config.oauth_token   = 'JL3V9K5WbQDW5YkCsp'
		config.oauth_secret  = 'sxrreXwrd9tJBmpYcetaPt8h9cU2ezzF'
		# config.client_id     = 'consumer_key'
		# config.client_secret = 'consumer_secret'
		config.adapter       = :net_http
		config.basic_auth    = 'alessiosantocs:282701'

	end

	puts bitbucket.issues.list_repo('pazientidevs', 'pazienti2', {:filter => 'kind=enhancement'})

	
	def track_deploy
		# autoload :App, 'deployd/app'
		deploy = Parse::Object.new("Deploy")

		deploy.save
	end

end
