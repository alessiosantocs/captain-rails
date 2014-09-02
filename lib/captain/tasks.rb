require 'net/http'

namespace :captain do
	task :start => :environment do

		# Deploying TO [app environment] 
		# 			BRANCH [the master branch] of the 
		# 			REPO [repo address] 
		# 			REVISION [latest commit hex] 
		release_env 	= ENV['TO']
		repo 			= ENV['REPO']
		rev 			= ENV['REVISION']
		branch 			= ENV['BRANCH']

		# Retrieve author email and name from env
		commit_author_name = ENV['COMMIT_AUTHOR_NAME']
		commit_author_email = ENV['COMMIT_AUTHOR_EMAIL']

		# Get the app id from the gem config object
		app_id 			= Captain.config.public_key

		# Up to you to use ssl
		use_ssl 		= false || ENV['USE_SSL']

		puts "Deploying Repo(#{repo} at #{branch}) on #{release_env} server heading #{rev}"

		uri = URI.parse('http://deploydapp.herokuapp.com/api/v1/deployments') # Insert the address of the application api

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true if use_ssl

		request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})

		data = {
			:deployment => {
				:repo => repo,
				:environment => release_env,
				:branch => branch,
				:revision => rev,
				:deployable_application_id => app_id,
				:author_name => commit_author_name,
				:author_email => commit_author_email
			}
		}

		request.body = data.to_json

		response = http.request(request)

		puts response.body
	end

	desc "Task to install the gem requirements"
	task :install, [:public_token] do |t, args|
		public_token 	= args[:public_token]

      	# call the API
      	uri = URI.parse("http://deploydapp.herokuapp.com/api/v1/deployable_applications/#{public_token}/activate") # Insert the address of the application api

		http = Net::HTTP.new(uri.host, uri.port)
		# http.use_ssl = true if use_ssl

		request = Net::HTTP::Put.new(uri.path, {'Content-Type' =>'application/json'})

		response = http.request(request)
		
		if response.kind_of?(Net::HTTPOK)
			source 			= File.join(File.dirname(__FILE__), '..', '..', 'config', 'initializers', 'captain.rb')
			destination 	= File.new(Rails.root.to_s + '/config/initializers/captain.rb', 'w')

			# FileUtils.cp(source, destination)

			IO.readlines(source.to_s).each do |line|
				str = line
				str = "\tconfig.public_key = '#{public_token}'" if str.index('config.public_key').present?

				destination.write(str + "\n")
			end

			destination.close
		end

		if File.exist?(Rails.root.to_s + '/config/deploy.rb')
			# install gem requirements on deploy config
			deploy_file = File.new(Rails.root.to_s + '/config/deploy.rb', 'a')

			deploy_file.write("require '../config/boot'")
			deploy_file.write("require 'deployd/capistrano'")

			deploy_file.close
		end
	end
end
