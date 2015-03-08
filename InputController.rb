# Retrieves the touches on the pad
class InputController
	attr_reader		:touchpad_height
	attr_reader		:touchpad_width
	attr_reader		:touchpad_center

	attr_reader		:left_edge
	attr_reader		:right_edge
	attr_reader		:top_edge
	attr_reader		:bottom_edge

	def initialize(runDaemon)
		system("syndaemon -m 10 -i 0.5 -K -t -d &") if runDaemon

		data = CommandLine.execute("synclient -l | grep ScrollDelta | grep -v -e Circ").split("\n")
		vScrollDelta = data[0].split("= ")[1].to_i
		hScrollDelta = data[1].split("= ")[1].to_i
		@scrollDelta = Vector.new(hScrollDelta, vScrollDelta)

		system "synclient ClickFinger3=1 TapButton3=2"

		data = CommandLine.execute("synclient -l | grep Edge | grep -v -e Area -e Motion -e Scroll").split("\n")

		@left_edge = data[0].split("= ")[1].to_i
		@right_edge = data[1].split("= ")[1].to_i
		@top_edge = data[2].split("= ")[1].to_i
		@bottom_edge = data[3].split("= ")[1].to_i

		@touchpad_height = (@top_edge-@bottom_edge).abs
		@touchpad_width = (@left_edge-@right_edge).abs

		@touchpad_center = Vector.new(@left_edge + @touchpad_width/2, @top_edge + @touchpad_height/2)
	end

	# Main method. To use as a iterator, yields time, x, y, z, fingers and click
	def poll(interval)
		Open3.popen3("synclient -m #{interval}") do |stdin, stdout, stderr|
			while line=stdout.gets.chomp
				time, x, y, z, fingers, w, click, more = line.split(" ")
				next if time == "time"
				time = time.to_f
				fingers = fingers.to_i
				click = click.to_i
				x, y = x.to_i, y.to_i
				z = z.to_i

				yield time, x, y, z, fingers, click
			end
		end
	end
end
