class Channel
	attr_accessor :members,:modes

	def initialize(mode)
		@modes = mode
	end
end