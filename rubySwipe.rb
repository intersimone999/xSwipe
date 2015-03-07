#!/usr/bin/ruby
##########################################################################
#   #      #  #   #          #####  #           #   #  ####   #####      #
#   #      #   # #          #        #   # #   #    #  #   #  #          #
#   #      #    #     ###    ####     #   #   #     #  ####   ###        #
#    #    #    # #               #     # # # #      #  #      #          #
#      ##     #   #         #####       #   #       #  #      #####      #
##########################################################################
# This is the Ruby version of xSwipe (written in Perl).                  #
# It uses an external Perl script in order to simulate X11 interactions  #
##########################################################################

require 'open3'

class CommandLine
	def CommandLine.execute(command)
		output = ""
		Open3.popen3(command) do |stdin, stdout, stderr|
			output = stdout.read
		end
		return output
	end
end

class Vector
	attr_reader	:x
	attr_reader	:y

	def initialize(x, y)
		@x = x.to_f
		@y = y.to_f
	end

	def angle
		angle = Math.atan(@y/@x)
		if @x > 0 and @y < 0
			angle += 2*Math::PI
		elsif @x < 0
			angle += Math::PI
		end
		
		return (angle * 360) / (Math::PI*2)
	end

	def magnitude
		return Math.sqrt(@x**2 + @y**2)
	end

	def zero?
		return (@x == 0.0 and @y == 0.0)
	end

	def set(x, y)
		@x = x.to_f
		@y = y.to_f
	end

	def add(x, y)
		@x += x
		@y += y
	end

	def addVector(v)
		add(v.x, v.y)
	end

	def reset
		@x = 0.0
		@y = 0.0
	end

	def inspect
		string = ""
		#string += "[#@x, #@y]\n"
		string += "{#{self.magnitude}, #{self.angle}}"
		return string
	end
end

class MeanVector < Vector
	def initialize(x, y)
		super

		@n = 0
	end

	def add(x, y)
		@x = (@n*@x + x) / (@n+1)
		@y = (@n*@y + y) / (@n+1)
		@n += 1
	end

	def reset
		super
		@n = 0
	end
end

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

# Retrieves the touches on the pad
class InputController
	attr_reader	:direction
	attr_reader	:position

	attr_reader	:touchpadHeight
	attr_reader	:touchpadWidth

	attr_reader	:leftEdge
	attr_reader	:rightEdge
	attr_reader	:topEdge
	attr_reader	:bottomEdge

	attr_accessor	:timeTolerance
	attr_accessor	:magnitudeTolerance
	attr_accessor	:angleTolerance
	attr_accessor	:repTime

	def initialize(runDaemon)
		@position = Vector.new(0, 0)
		@direction = MeanVector.new(0, 0)
		@iDirection = Vector.new(0, 0)

		@z = 0

		system("syndaemon -m 10 -i 0.5 -K -t -d &") if runDaemon

		data = CommandLine.execute("synclient -l | grep ScrollDelta | grep -v -e Circ").split("\n")
		vScrollDelta = data[0].split("= ")[1].to_i
		hScrollDelta = data[1].split("= ")[1].to_i
		@scrollDelta = Vector.new(hScrollDelta, vScrollDelta)

		system "synclient ClickFinger3=1 TapButton3=2"

		data = CommandLine.execute("synclient -l | grep Edge | grep -v -e Area -e Motion -e Scroll").split("\n")

		@leftEdge = data[0].split("= ")[1].to_i
		@rightEdge = data[1].split("= ")[1].to_i
		@topEdge = data[2].split("= ")[1].to_i
		@bottomEdge = data[3].split("= ")[1].to_i

		@touchpadHeight = (@topEdge-@bottomEdge).abs
		@touchpadWidth = (@leftEdge-@rightEdge).abs

		reset
	end

	def reset
		@currentRepetitionTime = @timeTolerance
		@canBeTriggered = true
		@isEdge = false
		@isMoving = false
		@swipeStart = nil
		@fingers = 0
		@position.reset
		@direction.reset
	end

	def edge?
		return @isEdge
	end

	# Returns true if moving
	def moving?
	end

	# Main method. To use as a iterator, yields fingers, axis and rate
	def mainloop(interval)
		Open3.popen3("synclient -m #{interval}") do |stdin, stdout, stderr|
			while line=stdout.gets.chomp
				time, x, y, z, fingers, w, click, more = line.split(" ")
				next if time == "time"
				time = time.to_f
				fingers = fingers.to_i
				click = click.to_i
				
				if fingers == 0
					reset
					next
				end
				@fingers = fingers if @fingers == 0

				x, y = x.to_i, y.to_i
				@z = z.to_i

				unless @position.zero?
					@direction.add(x - @position.x, y - @position.y)
					@iDirection.set(x - @position.x, y - @position.y)
				end

				p @direction if $debug

				@position.set(x, y)

				if @swipeStart == nil
					@swipeStart = time
					@isEdge = true if @position.x < @leftEdge || @position.x > @rightEdge
				end

				if @fingers != fingers
					@fingers = fingers
					@swipeStart = time
				end

				if (@canBeTriggered &&											#If the action can be triggered
						time - @swipeStart >= @currentRepetitionTime && 		#If enough time is passed
						@direction.magnitude >= @magnitudeTolerance &&			#If the strength is enough
						!@iDirection.angle.nan? && @iDirection.angle.between?(@direction.angle-@angleTolerance, @direction.angle+@angleTolerance)) #If the angle is right
					@swipeStart = time
					@currentRepetitionTime = @repTime
					@canBeTriggered = !yield(@fingers)
				end
			end
		end
	end
end

class InputHandler
	attr_accessor	:timeTolerance
	attr_accessor	:magnitudeTolerance
	attr_accessor	:angleTolerance
	attr_accessor	:repTime

	def initialize(input)
		@input = input

		@position = Vector.new(0, 0)
		@direction = MeanVector.new(0, 0)
		@iDirection = Vector.new(0, 0)

		@z = 0

		reset
	end

	def reset
		@currentRepetitionTime = @timeTolerance
		@canBeTriggered = true
		@isEdge = false
		@isMoving = false
		@swipeStart = nil
		@fingers = 0
		@position.reset
		@direction.reset
	end

	def mainloop
		@input.each_event do |time, x, y, z, fingers, w, click|
			if fingers == 0
				reset
				next
			end
			@fingers = fingers if @fingers == 0

			x, y = x.to_i, y.to_i
			@z = z.to_i

			unless @position.zero?
				@direction.add(x - @position.x, y - @position.y)
				@iDirection.set(x - @position.x, y - @position.y)
			end

			p @direction if $debug

			@position.set(x, y)

			if @swipeStart == nil
				@swipeStart = time
				@isEdge = true if @position.x < @input.leftEdge || @position.x > @input.rightEdge
			end

			if @fingers != fingers
				@fingers = fingers
				@swipeStart = time
			end

			if (@canBeTriggered &&											#If the action can be triggered
					time - @swipeStart >= @currentRepetitionTime && 		#If enough time is passed
					@direction.magnitude >= @magnitudeTolerance &&			#If the strength is enough
					!@iDirection.angle.nan? && @iDirection.angle.between?(@direction.angle-@angleTolerance, @direction.angle+@angleTolerance)) #If the angle is right
				@swipeStart = time
				@currentRepetitionTime = @repTime
				@canBeTriggered = !yield(@fingers)
			end
		end
	end
end

# Handles the actions
class ActionHandler
	attr_accessor	:magnitude

	def initialize(config)
		@config = config
		@pipeSend, @pipeRec, @pipeErr = Open3.popen3("perl rubySwipeActions.pl")
	end

	def onSwipeLeft(fingers)
		action, magnitude, onetime = *getAllData(:swipe, fingers, :left)
		doAction(action) if checkMagnitude magnitude

		return onetime
	end

	def onSwipeRight(fingers)
		action, magnitude, onetime = *getAllData(:swipe, fingers, :right)
		doAction(action) if checkMagnitude magnitude

		return onetime
	end

	def onSwipeUp(fingers)
		action, magnitude, onetime = *getAllData(:swipe, fingers, :up)
		doAction(action) if checkMagnitude magnitude

		return onetime
	end

	def onSwipeDown(fingers)
		action, magnitude, onetime = *getAllData(:swipe, fingers, :down)
		doAction(action) if checkMagnitude magnitude

		return onetime
	end

	def onSwipeEdgeLeft(fingers)
		action, magnitude, onetime = *getAllData(:edgeSwipe, fingers, :left)
		doAction(action) if checkMagnitude magnitude

		return onetime
	end

	def onSwipeEdgeRight(fingers)
		action, magnitude, onetime = *getAllData(:edgeSwipe, fingers, :right)
		doAction(action) if checkMagnitude magnitude

		return onetime
	end

	def onStartMoving()
		puts "Start moving"
	end

	def onEndMoving()
		puts "End moving"
	end

	def onPinchIn()
		puts "Pinching in"
	end

	def onPinchOut()
		puts "Pinching out"
	end

	def doAction(action)
		return if action == "default"

		@pipeSend.puts("SendKeys/#{action}")
	end

	def getAllData(*path)
		acp = path + [:action]
		mgp = path + [:magnitude]
		ot = path + [:onetime]

		action = @config.get(*acp)
		magnitude = @config.get(*mgp)
		onetime = @config.get(*ot)
		onetime = false if onetime == "default"

		return action, magnitude, onetime
	end

	def checkMagnitude(magnitude)
		return true unless magnitude.is_a? Numeric
		return @magnitude >= magnitude
	end
end

# Controls the modules in order to perform all the actions
class MainController
	def main(runDaemon=false)
		@config = ConfigHandler.new
		timeTolerance 	= @config.get :timeTolerance
		magTolerance 	= @config.get :magnitudeTolerance
		angleTolerance 	= @config.get :angleTolerance
		pollingInterval	= @config.get :pollingInterval
		repTime			= @config.get :repTime

		@action = ActionHandler.new @config
		
		@input = InputController.new(runDaemon)
		@input.timeTolerance = timeTolerance
		@input.magnitudeTolerance = magTolerance
		@input.angleTolerance = angleTolerance
		@input.repTime = repTime
		
		@input.mainloop(pollingInterval) do |fingers|
			@action.magnitude = @input.direction.magnitude

			angle = @input.direction.angle
			
			if angle < angleTolerance || angle > 360-angleTolerance
				if @input.edge?
					@action.onSwipeEdgeRight(fingers) 
				else
					@action.onSwipeRight(fingers)
				end
			elsif angle.between?(90-angleTolerance, 90+angleTolerance)
				@action.onSwipeDown(fingers)
			elsif angle.between?(180-angleTolerance, 180+angleTolerance)
				if @input.edge?
					@action.onSwipeEdgeLeft(fingers) 
				else
					@action.onSwipeLeft(fingers)
				end
			elsif angle.between?(270-angleTolerance, 270+angleTolerance)
				@action.onSwipeUp(fingers)
			end
			#Don't insert anything here! Return of @action.on[ActionType] is needed by mainloop for onetime support
		end
	end
end

runDaemon = ARGV.include?("-d") || ARGV.include?("--daemon")
run = ARGV.include?("-r") || ARGV.include?("--run")
$debug = ARGV.include?("-D") || ARGV.include?("--debug")

MainController.new.main(runDaemon) if run
