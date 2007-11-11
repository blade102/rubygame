require 'rubygame/gl/matrix3'
require 'rubygame/gl/point2'
require 'rubygame/gl/vector2'

# Transform2 stores 2D transformation information as attributes:
# 
# angle:: rotation about the forward axis. A Numeric, in radians.
# scale:: scaling factor on X and Y. A Vector2.
# shear:: shearing amount on X and Y. A Vector2.
# shift:: translation, i.e. movement, on X and Y. A Vector2.
# pivot:: apply the operations with this as the origin. A Point2.
# 
# It can be converted to a Matrix3 to composite transformations or
# apply the transformation to a Vector2 or Point2.
# 
class Transform2
	attr_accessor :angle, :scale, :shear, :shift, :pivot

	class << self
		def translate( shift )
			self.new( :shift => shift )
		end
		
		alias :shift :translate
		alias :move  :translate
		
		def rotate( angle )
			self.new( :angle => angle )
		end
		
		def scale( scale )
			self.new( :scale => scale )
		end
		
		def rotate_from( angle, pivot )
			self.new( :angle => angle, :pivot => pivot )
		end
		
		def scale_from( scale, pivot )
			self.new( :scale => scale, :pivot => pivot )
		end
		
	end
	
	def initialize( description = {} )
		unless description.kind_of? Hash
			raise ArgumentError, "#{self.class.name}.new takes 1 Hash argument. Got #{description.class.name}."
		end
		
		@angle = (description[:angle])
		@scale = (description[:scale])
		@shear = (description[:shear])
		@shift = (description[:shift])
		@pivot = (description[:pivot])
		
		# Scale is allowed to be 1 number for uniform scale,
		# or an Array of 2 numbers for nonuniform scale.
		case @scale
		when Numeric
			@scale = Vector2[@scale, @scale]
		when Array
			@scale = Vector2[*@scale]
		end
		
		@shear = @shear ? Vector2[*@shear] : nil
		@shift = @shift ? Vector2[*@shift] : nil
		@pivot = @pivot ?  Point2[*@pivot] : nil
	end

	def ==( other )
		@angle == other.angle and\
		@scale == other.scale and\
		@shear == other.shear and\
		@shift == other.shift and\
		@pivot == other.pivot
	rescue NoMethodError
		false
	end
	
	# Apply the transformation to a Vector2 or Point2, or
	# combine transformations with a Matrix3 or Transform2.
	# 
	# NOTE: When combining transformations, the effect of this
	# transformation will occur **after** the other one.
	# See Matrix3#* for more information.
	def *( other )
		c = Math.cos(@angle)
		s = Math.sin(@angle)
		
		case other
		when Vector2
			return self.to_m*other
		when Point2
			return self.to_m*other
		when Matrix3
			return self.to_m*other
		when Transform2
			return self.to_m*other.to_m
		end
	end
	
	# Convert to 3x3 transformation matrix
	def to_m
		result = Matrix3.identity
		
		# Apply the pivot shift
		if @pivot
			reverse_pivot = -(@pivot.to_v)
			result = Matrix3.translate(*reverse_pivot) * result
		end

		# Apply shearing
		if @shear
			result = Matrix3.shear(*@shear) * result
		end
		
		# Apply scaling
		if @scale
			result = Matrix3.scale(*@scale) * result
		end
		
		# Apply rotation
		if @angle
			result = Matrix3.rotate(@angle) * result
		end
		
		# Apply translation
		if @shift
			result = Matrix3.translate(*@shift) * result
		end
		
		# Undo the pivot shift
		if @pivot
			result = Matrix3.translate(*@pivot) * result
		end		
		
		return result
	end
end