# Defines deploy:notify_captain which will send information about the deploy to Captain.
require 'capistrano'

module Captain
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
				after "deploy",            "captain:deploy"
				after "deploy:migrations", "captain:deploy"
				after "deploy:cold",       "captain:deploy"

				namespace :captain do
					desc <<-DESC
						Notify Captain of the deployment by running the notification on the REMOTE machine.
							- Run remotely so we use remote API keys, environment, etc.
					DESC
					task :deploy, :except => { :no_release => true } do
						# Get environment, branch, local user, executable
						rails_env 	= fetch(:rails_env, "production")
						captain_env = fetch(:captain_env, fetch(:rails_env, "production"))
						branch 		= fetch(:branch, "master")
						local_user 	= ENV['USER'] || ENV['USERNAME']
						executable 	= RUBY_PLATFORM.downcase.include?('mswin') ? fetch(:rake, 'rake.bat') : fetch(:rake, 'bundle exec rake ')
						directory 	= configuration.release_path
						
						# Get the username and email from local git
						local_author_name = `git config --get user.name`
						local_author_email = `git config --get user.email`

						# Create the basic command
						notify_command = "cd #{directory}; #{executable} RAILS_ENV=#{rails_env} captain:start TO=#{captain_env} REVISION=#{current_revision} REPO=#{repository} BRANCH=#{branch} USER=#{Captain::Capistrano::shellescape(local_user)} COMMIT_AUTHOR_NAME=#{local_author_name} COMMIT_AUTHOR_EMAIL=#{local_author_email}"
						notify_command << " DRY_RUN=true" if dry_run
						notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
						
						logger.info "Notifying Captain of Deploy (#{notify_command})"
						if configuration.dry_run
							logger.info "DRY RUN: Notification not actually run."
						else
							result = ""
							run(notify_command, :once => true) { |ch, stream, data| result << data }
							# TODO: Check if SSL is active on account via result content.
						end
						puts "Captain Notification Complete. CALLING THE RAKE"
					end
				end
			end
		end
	end
end

if Capistrano::Configuration.instance
	Captain::Capistrano.load_into(Capistrano::Configuration.instance)
end