module ContextsadderHelper
	# class that just keeps a count as I could not figure out how to keep count in the JSONBuilder loops
	class Iobj
		@i = 0

		def initialize()
			@i = 0
		end

		def currentI()
			return @i
		end

		def getI
			@i += 1
			return @i
		end
	end
end
