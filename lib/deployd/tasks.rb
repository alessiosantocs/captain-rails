require 'net/http'

namespace :deployd do
	task :start do

		release_env 	= ENV['TO']
		repo 			= ENV['REPO']
		rev 			= ENV['REVISION']
		branch 			= ENV['BRANCH']
		app_id 			= ENV['APP_ID']

		use_ssl 		= false || ENV['USE_SSL']

		puts "Deploying Repo(#{repo} at #{branch}) on #{release_env} server heading #{rev}"
		commit = `git log --format="%H" -n 1`

		uri = URI.parse('http://localhost:3000/api/v1/deployments') # Insert the address of the application api

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true if use_ssl

		request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})

		data = {
			:deployment => {
				:repo => repo,
				:environment => release_env,
				:branch => branch,
				:revision => rev,
				:deployable_application_id => app_id
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
      	uri = URI.parse("http://localhost:3000/api/v1/deployable_applications/#{public_token}/activate") # Insert the address of the application api

		http = Net::HTTP.new(uri.host, uri.port)
		# http.use_ssl = true if use_ssl

		request = Net::HTTP::Put.new(uri.path, {'Content-Type' =>'application/json'})

		response = http.request(request)
		
		if response.kind_of?(Net::HTTPOK)
			source 			= File.join(File.dirname(__FILE__), '..', '..', 'config', 'initializers', 'deployd.rb')
			destination 	= File.new(Rails.root.to_s + '/config/initializers/deployd.rb', 'w')

			# FileUtils.cp(source, destination)

			IO.readlines(source.to_s).each do |line|
				str = line
				str = "\tconfig.token = '#{public_token}'" if str.index('config.token').present?

				destination.write(str + "\n")
			end

			destination.close
		end
	end
end
