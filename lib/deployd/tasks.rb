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

		uri = URI.parse('http://localhost:4000/api/v1/deployments') # Insert the address of the application api

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
end
