# Handles configuration file. Initially loads all configurations
class ConfigHandler
	FILENAME = "eventKey.cfgr"

	def initialize
		File.open FILENAME, "rb" do |f|
			content = f.read
			@config = parse content
		end
	end

	def get(*path)
		current = @config
		for key in path
			return "default" unless current
			current = current[key]
		end
		return "default" unless current
		return current
	end

	def parse(content)
		return eval content
	end
end
