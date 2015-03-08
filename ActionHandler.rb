# Handles the actions
class ActionHandler
	MOUSE_LEFT	= "MLEFT"
	MOUSE_RIGHT = "MRIGHT"
	MOUSE_CENTER = "MCENTER"
	def initialize
		@pipeSend, @pipeRec, @pipeErr = Open3.popen3("perl rubySwipeActions.pl")
	end

	def sendKeys(action)
		return if action == "default"

		@pipeSend.puts "SendKeys/#{action}"
	end

	def pressKey(action)
		return if action == "default"

		@pipeSend.puts "PressKey/#{action}"
	end
	
	def releaseKey(action)
		return if action == "default"

		@pipeSend.puts "ReleaseKey/#{action}"
	end

	def pressMouseButton(button)
		@pipeSend.puts "PressMouseButton/#{button}"
	end

	def releaseMouseButton(button)
		@pipeSend.puts "ReleaseMouseButton/#{button}"
	end
end
