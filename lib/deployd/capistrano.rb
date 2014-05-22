# Defines deploy:notify_deployd which will send information about the deploy to Deployd.
require 'capistrano'

module Deployd
	module Capistrano
		# Returns an empty quoted String if +str+ has a length of zero.
		def self.shellescape(str)
			str = str.to_s

			# An empty argument will be skipped, so return empty quotes.
			return "''" if str.empty?

			str = str.dup

			# Treat multibyte characters as is.  It is caller's responsibility
			# to encode the string in the right encoding for the shell
			# environment.
			str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")

			# A LF cannot be escaped with a backslash because a backslash + LF
			# combo is regarded as line continuation and simply ignored.
			str.gsub!(/\n/, "'\n'")

			return str
		end

		def self.load_into(configuration)
			configuration.load do
				after "deploy",            "deployd:deploy"
				after "deploy:migrations", "deployd:deploy"
				after "deploy:cold",       "deployd:deploy"

				namespace :deployd do
					desc <<-DESC
						Notify Deployd of the deployment by running the notification on the REMOTE machine.
							- Run remotely so we use remote API keys, environment, etc.
					DESC
					task :deploy, :except => { :no_release => true } do
						rails_env 	= fetch(:rails_env, "production")
						deployd_env = fetch(:deployd_env, fetch(:rails_env, "production"))
						branch 		= fetch(:branch, "master")
						local_user 	= ENV['USER'] || ENV['USERNAME']
						executable 	= RUBY_PLATFORM.downcase.include?('mswin') ? fetch(:rake, 'rake.bat') : fetch(:rake, 'bundle exec rake ')
						directory 	= configuration.release_path
						
						notify_command = "cd #{directory}; #{executable} RAILS_ENV=#{rails_env} deployd:start TO=#{deployd_env} REVISION=#{current_revision} REPO=#{repository} BRANCH=#{branch} USER=#{Deployd::Capistrano::shellescape(local_user)}"
						notify_command << " DRY_RUN=true" if dry_run
						notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
						
						logger.info "Notifying Deployd of Deploy (#{notify_command})"
						if configuration.dry_run
							logger.info "DRY RUN: Notification not actually run."
						else
							result = ""
							run(notify_command, :once => true) { |ch, stream, data| result << data }
							# TODO: Check if SSL is active on account via result content.
						end
						puts "Deployd Notification Complete. CALLING THE RAKE"
					end
				end
			end
		end
	end
end

if Capistrano::Configuration.instance
	Deployd::Capistrano.load_into(Capistrano::Configuration.instance)
end