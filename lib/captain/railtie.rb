require 'rails'

module Captain
	class Railtie < Rails::Railtie
		rake_tasks do
			require 'captain/tasks'
		end
	end
end
