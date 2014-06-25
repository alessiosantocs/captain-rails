require 'rails'

module Captain
	class Railtie < Rails::Railtie
		puts "================= THERE WE GO"
		rake_tasks do
			require 'captain/tasks'
		end
	end
end
