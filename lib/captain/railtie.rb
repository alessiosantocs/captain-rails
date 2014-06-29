require 'captain-rails'
require 'rails'

module Captain
	class Railtie < ::Rails::Railtie
		logger.info "Including tasks.rb"
		rake_tasks do
			require 'captain/tasks'
		end
	end
end
