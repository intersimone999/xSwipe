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

	def -(vector)
		return Vector.new(0,0) unless vector.is_a? Vector

		return Vector.new(self.x-vector.x, self.y-vector.y)
	end

	def parallel?(vector, tolerance=5)
		angle1 = self.angle
		angle2 = vector.angle
		return false if angle1.nan? or angle2.nan?
		return true if angle1.between?(angle2-tolerance, angle2+tolerance)
		return true if ( (angle1 + 180) % 360 ).between?(angle2-tolerance, angle2+tolerance)
	end

	def concorde?(vector, tolerance=5)
		angle1 = self.angle
		angle2 = vector.angle

		return false if angle1.nan? or angle2.nan?
		return true if angle1.between?(angle2-tolerance, angle2+tolerance)
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
