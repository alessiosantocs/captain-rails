require 'rails'

module Deployd
	class Railtie < Rails::Railtie
		rake_tasks do
			require 'deployd/tasks'
		end
	end
end
