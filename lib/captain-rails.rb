require "json"
require "captain/version"
require "captain/config"

module Captain
	logger.info "Including Railtie.rb"
	require "captain/railtie.rb" if defined?(Rails)

	@config = Captain::Config.new

	def self.config

		if block_given?
			yield(@config)
		else
			@config
		end

	end
end
