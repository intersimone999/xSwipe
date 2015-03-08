class InputHandler
	attr_reader		:direction
	attr_reader		:position

	attr_accessor	:time_tolerance
	attr_accessor	:magnitude_tolerance
	attr_accessor	:angle_tolerance
	attr_accessor	:repetition_time
	attr_accessor	:polling_interval

	attr_accessor	:move_fingers

	def initialize(input)
		@input = input

		@position = Vector.new(0, 0)
		@direction = MeanVector.new(0, 0)
		@last_direction = Vector.new(0, 0)

		@z = 0
		@is_moving = false

		reset
	end

	def reset
		@current_repetition_time = @time_tolerance
		@can_be_triggered = true
		@is_edge = false
		@swipe_start = nil
		@pinch_start = nil
		@fingers = 0
		@position.reset
		@direction.reset
		@last_direction.reset
	end

	def edge?
		return @is_edge
	end
	
	def moving?
		return @is_moving
	end

	def swiping?
		return @swipe_start != nil
	end

	def mainloop(responder)
		@input.poll @polling_interval do |time, x, y, z, fingers, click|
			if fingers == 0
				if @is_moving
					responder.onEndMoving
					@is_moving = false
				end

				reset
				next
			end

			#Updates the direction of the gesture and the position of the fingers
			unless @position.zero?
				@direction.add(x - @position.x, y - @position.y)
				@last_direction.set(x - @position.x, y - @position.y)
			end
			@position.set(x, y)

			#Prints debug information
			#p @direction if $debug

			#If no gesture is currently performing, starts a gesture recording
			if not swiping?
				@swipe_start = time
				@pinch_start = time
				@is_edge = true if @position.x < @input.left_edge || @position.x > @input.right_edge
				@fingers = fingers
				p @fingers, @is_edge, @position if $debug
			end

			#If the number of fingers change, resets the recording
			if @fingers != fingers
				reset

				@is_edge = true if @position.x < @input.left_edge || @position.x > @input.right_edge
				@fingers = fingers
				@swipe_start = time
			end

			#Pinch recognition not working
			#if @fingers == 2 && time-@pinch_start.to_i >= 2
			#	p oracle_vector = (@position-@input.touchpad_center)
			#	if oracle_vector.parallel? @direction
			#		if oracle_vector.concorde? @direction
			#			responder.onPinchIn
			#		else
			#			responder.onPinchOut
			#		end
			#	end
			#	@pinch_start = time
			#end

			if !@is_moving && @fingers == @move_fingers
				responder.onStartMoving
				@is_moving = true
			end

			#If the condition is satisfied, triggers the swipe action
			if 		@can_be_triggered &&										#If the action can be triggered (used to prevent multiple triggers on one-time actions)
					time - @swipe_start >= @current_repetition_time && 			#If enough time has passed
					@direction.magnitude >= @magnitude_tolerance &&				#If the strength is enough
					!@last_direction.angle.nan? && 
					@last_direction.angle.between?(@direction.angle-@angle_tolerance, @direction.angle+@angle_tolerance) #If the angle is right
				@swipe_start = time
				@current_repetition_time = @repetition_time
				@can_be_triggered = !responder.onSwipe(@fingers)
			end
		end
	end
end
