class GetDocController < ApplicationController

# @result should probably be turned into a Model and passed to the view that way
# It would make it better

	def get_document
		@result = []

		if params[:num] != nil
			num = params[:num]
			puts "the docNum is: " + num

			require 'socket'
			s = TCPSocket.new @@address, @@port
			puts 'LOG:made conncetion'

			s.puts "doc " + num


			# s.puts command # put command here
			# s.puts "search god|england"

			response = s.gets
			# puts '% res : ' + response
			puts "about to be pushed: " + response.to_s
			@result.push(response)

			while !(response.include? '--') do
			  	# puts response
			  	# puts '% getting new res, current: ' + response + ' bool: ' + (response.include? '--').to_s
			  	response = s.gets
			  	puts "about to be pushed: " + response.to_s
			  	@result.push(response)
			  	# puts '% res2 : ' + response
			  end

			  s.close
			 # puts 'LOG:result: ' + @result.to_s

			else
				result.push("Nothing matches")
			end
		end
	end
