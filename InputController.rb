# Retrieves the touches on the pad
class InputController
	attr_reader		:touchpad_height
	attr_reader		:touchpad_width
	attr_reader		:touchpad_center

	attr_reader		:left_edge
	attr_reader		:right_edge
	attr_reader		:top_edge
	attr_reader		:bottom_edge

	def initialize(runDaemon, event_id)
		#system("syndaemon -m 30 -i 0.5 -K -t -d &") if runDaemon

		data = CommandLine.execute("synclient -l | grep ScrollDelta | grep -v -e Circ").split("\n")
		vScrollDelta = data[0].split("= ")[1].to_i
		hScrollDelta = data[1].split("= ")[1].to_i
		@scrollDelta = Vector.new(hScrollDelta, vScrollDelta)

		#system "synclient ClickFinger3=1 TapButton3=2"
		#system "synclient TapButton1=1 LockedDrags=1 LockedDragTimeout=200"

		data = CommandLine.execute("synclient -l | grep Edge | grep -v -e Area -e Motion -e Scroll").split("\n")

		@left_edge = data[0].split("= ")[1].to_i
		@right_edge = data[1].split("= ")[1].to_i
		@top_edge = data[2].split("= ")[1].to_i
		@bottom_edge = data[3].split("= ")[1].to_i

		@touchpad_height = (@top_edge-@bottom_edge).abs
		@touchpad_width = (@left_edge-@right_edge).abs

		@touchpad_center = Vector.new(@left_edge + @touchpad_width/2, @top_edge + @touchpad_height/2)
                
                @event_id = event_id
	end

	# Main method. To use as a iterator, yields time, x, y, z, fingers and click
#	def poll(interval)
#		Open3.popen3("synclient -m #{interval}") do |stdin, stdout, stderr|
#			while line=stdout.gets.chomp
#				time, x, y, z, fingers, w, click, more = line.split(" ")
#				next if time == "time"
#				time = time.to_f
#				fingers = fingers.to_i
#				click = click.to_i
#				x, y = x.to_i, y.to_i
#				z = z.to_i
#                                
#				event = InputEvent.new
#				event.time = time
#				event.x = x
#				event.y = y
#				event.z = z
#				event.fingers = fingers
#				event.click = click
#
#				yield time, x, y, z, fingers, click
#			end
#		end
#	end
	
	# Main method. To use as a iterator, yields time, x, y, z, fingers and click
	def poll(interval)
		parser = InputParser.new
		Thread.start do
                    loop do
                        name = "evemu-record /dev/input/event#@event_id"
                        Open3.popen3(name) do |stdin, stdout, stderr|
                                start_time = Time.now
                                current_time = Time.now
                                while (line=stdout.gets)
                                    begin
                                        sync = parser.parse(line)
                                        
                                        #If enough time passed and the parser synched, re-open the stream
                                        break if sync && (current_time - start_time > 5)
                                    rescue
                                        p $!
                                        p $!.backtrace
                                    end
                                    current_time = Time.now
                                end
                        end
                    end
		end
		
		loop do
			sleep interval/1000.0
			break if parser.is_ready?
		end
		
		last_event = InputEvent.new
		last_event.time = 0
		loop do
			event = parser.event
			
			if (last_event.time != event.time)
				p event if $DEBUG
				yield event
			end
			
			last_event = event
			
			sleep interval/1000.0
		end
	end
end

class InputParser    
	EV_SYNC                 = "0000"
	
	EV_ABS_X                = "0000"
    EV_ABS_Y                = "0001"
	EV_ABS_PRESSURE         = "0003"
	
    EV_ABS_MT_SLOT          = "002f"
    EV_ABS_MT_POSITION_X    = "0035"
    EV_ABS_MT_POSITION_Y    = "0036"
    EV_ABS_MT_PRESSURE      = "003a"
    
    EV_BTN_TOOL_QUINTTAP    = "0148"
    EV_BTN_TOOL_QUADTAP     = "014f"
    EV_BTN_TOOL_TRIPLETAP   = "014e"
    EV_BTN_TOOL_DOUBLETAP   = "014d"
    EV_BTN_TOOL_FINGER      = "0145"
	
	EV_BTN_LEFT		        = "0110"
    
    def initialize
		@taps = {}
		@taps[1] = false 
		@taps[2] = false
		@taps[3] = false
		@taps[4] = false
		@taps[5] = false
		
		@current_event = nil
		
		@parsing_params = {}
        clear_parsing
    end
    
    def parse(line)
		return false unless line.start_with? "E:"
		
        real_line = line[3,23]
        
        time, type, event, value = real_line.split " "
        
        time = time.to_f
        value = value.to_i
		
        if type == EV_SYNC
            sync 
            return true
        end
        
        @current_time = time
		case event
			when EV_ABS_X
				@parsing_params['x'] = value
			when EV_ABS_Y
				@parsing_params['y'] = value
			when EV_ABS_PRESSURE
				@parsing_params['pressure'] = value
			
			
			when EV_ABS_MT_SLOT
				@parsing_params['slot'] = value
				@parsing_params['slots'][value] = {}
			when EV_ABS_MT_POSITION_X
				@parsing_params['slots'][@parsing_params['slot']]['x'] = value
			when EV_ABS_MT_POSITION_Y
				@parsing_params['slots'][@parsing_params['slot']]['y'] = value
			when EV_ABS_MT_PRESSURE
				@parsing_params['slots'][@parsing_params['slot']]['pressure'] = value
			
			
			when EV_BTN_TOOL_FINGER
				@parsing_params['tap1'] = (value == 0 ? false : true)
			when EV_BTN_TOOL_DOUBLETAP
				@parsing_params['tap2'] = (value == 0 ? false : true)
			when EV_BTN_TOOL_TRIPLETAP
				@parsing_params['tap3'] = (value == 0 ? false : true)
			when EV_BTN_TOOL_QUADTAP
				@parsing_params['tap4'] = (value == 0 ? false : true)
			when EV_BTN_TOOL_QUINTTAP
				@parsing_params['tap5'] = (value == 0 ? false : true)
				
			when EV_BTN_LEFT
				@parsing_params['button_left'] = (value == 0 ? false : true)
		end
		
		return false
    end
    
    def sync
		#Syncs the tap status
		@taps[1] = @parsing_params['tap1'] if (@parsing_params['tap1'] != nil)
		@taps[2] = @parsing_params['tap2'] if (@parsing_params['tap2'] != nil)
		@taps[3] = @parsing_params['tap3'] if (@parsing_params['tap3'] != nil)
		@taps[4] = @parsing_params['tap4'] if (@parsing_params['tap4'] != nil)
		@taps[5] = @parsing_params['tap5'] if (@parsing_params['tap5'] != nil)
		
		event = InputEvent.new
		@current_event = event unless @current_event
		
		event.time = @current_time
		event.fingers = fingers
		event.x = @parsing_params['x'] || @current_event.x
		event.y = @parsing_params['y'] || @current_event.y
		event.z = @parsing_params['pressure'] || @current_event.z
		
		event.single_fingers = {}
		@parsing_params['slots'].each do |key, value|
			event.single_fingers[key] = InputEvent.new
			event.single_fingers[key].x = value['x']
			event.single_fingers[key].y = value['y']
			event.single_fingers[key].z = value['pressure']
		end
		
		@current_event = event
		clear_parsing
    end
	
	def event
		return @current_event
	end
	
	def clear_parsing
		@parsing_params.clear
		@parsing_params['slot'] = 0
		@parsing_params['slots'] = {}
		@parsing_params['slots'][0] = {}
	end
    
    def fingers
		5.downto(1).each do |finger|
			return finger if is_tap? finger
		end
        
		return 0
    end
    
    def is_tap?(id)
		return @taps[id]
    end
    
    def is_ready?
		return @current_event != nil
    end
end

class InputEvent
    attr_accessor   :time
    attr_accessor   :fingers
    attr_accessor   :x
    attr_accessor   :y
    attr_accessor   :z
    attr_accessor   :click
	
	attr_accessor	:single_fingers
end
