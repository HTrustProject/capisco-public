class SearchController < ApplicationController
	
	
  	def results
		if params[:command] != nil
			command = params[:command].split(" ")
			puts "the command is: " + command[0]


			require 'socket'
			s = TCPSocket.new @@address, @@port
			puts 'LOG:made conncetion'

			case command[0]
			when "search"
				puts "ENTERED SEARCH"
				s.puts "search " + command[1]
			when "list"
				puts "ENTERED LIST"
				s.puts "list"
			else
				s.puts params[:command]
				puts "IN ELSE STATEMENT sent: " + params[:command]
			end

		end
		@result = []

		# s.puts command # put command here
	    # s.puts "search god|england"
	    response = s.gets
		# puts '% res : ' + response
		puts "about to be pushed: " + response.to_s
	  	@result.push(response)

	  while !(response.include? '--')
	  	# puts response
	  	# puts '% getting new res, current: ' + response + ' bool: ' + (response.include? '--').to_s
	  	response = s.gets
	  	puts "about to be pushed: " + response.to_s
	  	@result.push(response)
	  	# puts '% res2 : ' + response
	  end

	  s.close
	  # puts 'LOG:result: ' + @result.to_s
	end
  
  
end
