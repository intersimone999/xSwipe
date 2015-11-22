# Controls the modules in order to perform all the actions
class MainController
	def main(runDaemon=false)
		@config = ConfigHandler.new
                
                $DEBUG = @config.get :debug
                
		@time_tolerance 		= @config.get :timeTolerance
		@magnitude_tolerance      	= @config.get :magnitudeTolerance
		@angle_tolerance 		= @config.get :angleTolerance
		@polling_interval		= @config.get :pollingInterval
		@repetition_time		= @config.get :repTime
		@move_fingers			= @config.get :move, :fingers
		@move_key				= @config.get :move, :key

		@action = ActionHandler.new
		
		@controller = InputController.new runDaemon
		@input_interpreter = InputHandler.new @controller
		@input_interpreter.time_tolerance = @time_tolerance
		@input_interpreter.magnitude_tolerance = @magnitude_tolerance
		@input_interpreter.angle_tolerance = @angle_tolerance
		@input_interpreter.repetition_time = @repetition_time
		@input_interpreter.polling_interval = @polling_interval
		@input_interpreter.move_fingers = @move_fingers
		
                @input_interpreter.reset
		@input_interpreter.mainloop self
	end

	def onSwipe(fingers)
		angle = @input_interpreter.direction.angle
		
		if angle <= @angle_tolerance || angle >= 360-@angle_tolerance
			edge = @input_interpreter.edge.include? InputHandler::EDGE_LEFT
			return swipe fingers, :right, edge
		elsif angle.between?(90-@angle_tolerance, 90+@angle_tolerance)
			edge = @input_interpreter.edge.include? InputHandler::EDGE_TOP
			return swipe fingers, :down, edge
		elsif angle.between?(180-@angle_tolerance, 180+@angle_tolerance)
			edge = @input_interpreter.edge.include? InputHandler::EDGE_RIGHT
			return swipe fingers, :left, edge
		elsif angle.between?(270-@angle_tolerance, 270+@angle_tolerance)
			edge = @input_interpreter.edge.include? InputHandler::EDGE_BOTTOM
			return swipe fingers, :up, edge
		end
	end

	def onStartMoving
		@is_moving = true
		@action.pressKey(@move_key)
		@action.pressMouseButton(ActionHandler::MOUSE_LEFT)
		debug "MoveStart"
	end

	def onEndMoving
		@action.releaseMouseButton(ActionHandler::MOUSE_LEFT)
		@action.releaseKey(@move_key)
		@is_moving = false
		debug "MoveStop"
	end

	def onPinchIn
		@action.sendKeys(@config.get(:pinch, :in))
	end

	def onPinchOut
		@action.sendKeys(@config.get(:pinch, :out))
	end

	def swipe(fingers, direction, edge)
		action, magnitude, onetime, hold = nil

		if !@is_moving
			folder = (edge ? :edgeSwipe : :swipe)
			action, magnitude, onetime = *get_swipe_data(folder, fingers, direction)
                        
                        @action.sendKeys(action) if check_magnitude magnitude
		else
			action, hold, onetime = *get_move_swipe_data(:move, :swipe, fingers, direction)
                        
                        self.onEndMoving
                        @action.sendKeys(action) if check_magnitude magnitude
                        self.onStartMoving
                        
			pdebug hold
			self.onEndMoving unless hold
			magnitude = 0
		end
		
		debug "Simulating #{action}"

		return onetime
	end

	def get_swipe_data(*path)
		debug "Getting #{path.join(', ')}"
		acp = path + [:action]
		mgp = path + [:magnitude]
		otp = path + [:onetime]

		pdebug action = @config.get(*acp)
		magnitude = @config.get(*mgp)
		onetime = @config.get(*otp)
		onetime = false if onetime == "default"

		return action, magnitude, onetime
	end

	def get_move_swipe_data(*path)
		debug "Getting #{path.join(', ')}"
		acp = path + [:action]
		hlp = path + [:hold]
		otp = path + [:onetime]

		pdebug action = @config.get(*acp)
		pdebug hold = @config.get(*hlp)
		onetime = @config.get(*otp)
		onetime = false if onetime == "default"
		hold = true if hold == "default"

		return action, hold, onetime
	end

	def check_magnitude(magnitude)
		return true unless magnitude.is_a? Numeric
		return @input_interpreter.direction.magnitude >= magnitude
	end

	def debug info
		puts info if $debug
	end

	def pdebug info
		p info if $debug
	end
end
