class ContextsadderController < ApplicationController
	def get
		initial = params[:initial]
		contexts = params[:contexts].split("|")
		synonyms = params[:synonyms].split("|")

		showInitialContext = stringToBool(params[:showInitialContext])
		showContextContext = stringToBool(params[:showContextContext])
		showSynonymSynonym = stringToBool(params[:showSynonymSynonym])

		require 'socket'
		s = TCPSocket.new @@address, @@port
		
		dotArray = []
		count = 0
		initialContexts = getContextsHuman(initial, s)



		dotArray.push('"' + initial + '"[color=red,fontColor=white];')
		count += 1

		for c in contexts
			dotArray.push('"' + c + '"[color=red];')
			count += 1
		end

		if showInitialContext
			puts 'initialContexts: '
			puts initialContexts
			for c in initialContexts
				toPush = '"' + initial + '" -> "' + c + '";'
				dotArray.push(toPush)
				count += 1
			end
		end

		if showContextContext
			for c in contexts
				listOfContextsContextes = getContextsHuman(c, s)
				for cc in listOfContextsContextes
					toPush = '"' + c + '" -> "' + cc + '";'
					dotArray.push(toPush)
					count += 1
				end
			end		
		else
			puts "CHECK FOR LINKS FROM ADDED CONTEXTS TO INITAL"
			for c in contexts
				if(getContextsHuman(c, s).include? initial)
					toPush = '"' + c + '" -> "' + initial + '";'
					dotArray.push(toPush)
					count += 1
					# puts".....getContexts(" + c + ") DID include : " + initial
				else
					# puts".....getContexts(" + c + ") did not include : " + initial
				end
			end	
		end

		puts "CHECKS LINKS FROM INTIAL TO ADDED CONTEXTS"
		for c in contexts
			if(initialContexts.include? c)
				toPush = '"' + initial + '" -> "' + c + '";'
				dotArray.push(toPush)
				puts 'about to push1: ' + toPush
				count += 1
			else
				# puts".....initialContexts does not include : " + c
			end
		end

		puts "CHECKS LINKS FROM ADDED CONTEXTS TO ADDED CONTEXTS"
		for c in contexts
			contextsOfC1 = getContextsHuman(c, s)
			for addedContext in contexts
				if(contextsOfC1.include? addedContext)
					toPush = '"' + c + '" -> "' + addedContext + '";'
					puts 'about to push2: ' + toPush
					if(c == addedContext)
						puts 'did not push'
					else
						dotArray.push(toPush)
						count += 1
						puts 'pushed'
					end
				end
			end
		end

		puts 'ADDS synonyms'

		for sy in synonyms
			toPush = '"#' + sy + '"[color=blue,fontColor=white];'
			dotArray.push(toPush)
			
			synonymsList = getSynonymsByName(sy,s)
			for c in contexts
				if(synonymsList.include? c)
					toPush = '"#' + sy + '"[color=blue,fontColor=white] -> "' + c + '";'
					dotArray.push(toPush)
				end
			end
			if(synonymsList.include? initial)
				toPush = '"#' + sy + '"[color=blue,fontColor=white] -> "' + initial + '";'
				dotArray.push(toPush)
			end 
		end

		if showSynonymSynonym
			for sy in synonyms
				listOfSy = getSynonymsByName(sy, s)
				for sys in listOfSy
					toPush = '"#' + sy + '"[color=blue,fontColor=white] -> "#' + sys + '";'
					puts "about to push " + toPush
					dotArray.push(toPush)
				end
			end
		end


		puts dotArray



		returnString = ""

		for s in dotArray
			puts "Joined with: " + s
			returnString += s
		end

		puts 'the returnString is: ' + returnString

		respond_to do |format|
			format.html { render :text => returnString }
		end
	end

	def getNewJson
		initial = params[:concept]
		contexts = params[:contexts].split("|")
		symbols = params[:symbols].split("|")

		showInitialContexts = stringToBool(params[:showInitialContext])
		showContexts = stringToBool(params[:showContext])
		showSymbols = stringToBool(params[:showKey])

		require 'socket'
		s = TCPSocket.new @@address, @@port
		
		dotArray = []
		count = 0
		initialContexts = getContextsHuman(initial, s)

			dotArray.push('edge [length=175, color=gray]')

		dotArray.push('"' + initial + '"[color=red,fontColor=white,fontColor=black];')
		count += 1

		puts "initialContexts: ====================================="
		puts initialContexts

		puts "contexts: ====================================="
		puts contexts


		for ic in initialContexts
			for c in contexts
				if c == ic
					toPush = '"' + c + '" -> "' + initial + '"[label="is context for"];'
					dotArray.push(toPush)
					puts "pushed: " + toPush
				end
			end
		end

		for c in contexts
			dotArray.push('"' + c + '"[color=blue,fontColor=white];')
		end

		for sym in symbols
			dotArray.push('"#' + sym + '"[color=yellow,fontColor=black];')
		end

		puts 'here:'
		puts symbols.inspect

		for sym in symbols
			puts "sym: "
			puts symbols.inspect
			keymaps = getKeymapsByName(initial, s)
			puts "keymaps: "
			puts keymaps.inspect
			for k in keymaps
				if k.include? sym	
					toPush = '"#' + sym + '" -> "' + initial + '"[label="is symbol for"];'
					# toPush2 = '"' + k + '" -> "' + sym + '";'
					dotArray.push(toPush)
					# dotArray.push(toPush2)

					puts "toPush: " + toPush
					# puts "toPush2: " + toPush2 
				end
			end
		end

		# for c in contexts
		# 	dotArray.push('"' + c + '"[color=blue,fontColor=white];')
		# 	for ic in initialContexts
		# 		if ic.include? c
		# 			toPush = '"' + ic + '" -> "' + c + '";'
		# 			dotArray.push(toPush)
		# 		end
		# 	end
		# end

		# if showInitialContext
			# puts 'initialContexts: '
			# puts initialContexts
			# for c in initialContexts
				# toPush = '"' + initial + '" -> "' + c + '";'
				# dotArray.push(toPush)
				# count += 1
			# end
		# end

		# if showContext
		# 	for c in contexts
		# 		listOfContextsContextes = getContextsHuman(c, s)
		# 		for cc in listOfContextsContextes
		# 			toPush = '"' + c + '" -> "' + cc + '";'
		# 			dotArray.push(toPush)
		# 			count += 1
		# 		end
		# 	end		
		# else
		# 	puts "CHECK FOR LINKS FROM ADDED CONTEXTS TO INITAL"
		# 	for c in contexts
		# 		if(getContextsHuman(c, s).include? initial)
		# 			toPush = '"' + c + '" -> "' + initial + '";'
		# 			dotArray.push(toPush)
		# 			count += 1
		# 			# puts".....getContextsHuman(" + c + ") DID include : " + initial
		# 		else
		# 			# puts".....getContextsHuman(" + c + ") did not include : " + initial
		# 		end
		# 	end	
		# end

		# puts "CHECKS LINKS FROM INTIAL TO ADDED CONTEXTS"
		# for c in contexts
		# 	if(initialContexts.include? c)
		# 		toPush = '"' + initial + '" -> "' + c + '";'
		# 		dotArray.push(toPush)
		# 		puts 'about to push1: ' + toPush
		# 		count += 1
		# 	else
		# 		# puts".....initialContexts does not include : " + c
		# 	end
		# end

		# puts "CHECKS LINKS FROM ADDED CONTEXTS TO ADDED CONTEXTS"
		# for c in contexts
		# 	contextsOfC1 = getContextsHuman(c, s)
		# 	for addedContext in contexts
		# 		if(contextsOfC1.include? addedContext)
		# 			toPush = '"' + c + '" -> "' + addedContext + '";'
		# 			puts 'about to push2: ' + toPush
		# 			if(c == addedContext)
		# 				puts 'did not push'
		# 			else
		# 				dotArray.push(toPush)
		# 				count += 1
		# 				puts 'pushed'
		# 			end
		# 		end
		# 	end
		# end

		# puts 'ADDS synonyms'

		# for sy in synonyms
		# 	toPush = '"#' + sy + '"[color=blue,fontColor=white];'
		# 	dotArray.push(toPush)

		# 	synonymsList = getSynonymsByName(sy,s)
		# 	for c in contexts
		# 		if(synonymsList.include? c)
		# 			toPush = '"#' + sy + '"[color=blue,fontColor=white] -> "' + c + '";'
		# 			dotArray.push(toPush)
		# 		end
		# 	end
		# 	if(synonymsList.include? initial)
		# 		toPush = '"#' + sy + '"[color=blue,fontColor=white] -> "' + initial + '";'
		# 		dotArray.push(toPush)
		# 	end 
		# end

		# if showSynonymSynonym
		# 	for sy in synonyms
		# 		listOfSy = getSynonymsByName(sy, s)
		# 		for sys in listOfSy
		# 			toPush = '"#' + sy + '"[color=blue,fontColor=white] -> "#' + sys + '";'
		# 			puts "about to push " + toPush
		# 			dotArray.push(toPush)
		# 		end
		# 	end
		# end


		puts dotArray



		returnString = ""

		for s in dotArray
			# puts "Joined with: " + s
			returnString += s
		end

		puts 'the returnString is: ' + returnString

		respond_to do |format|
			format.html { render :text => returnString }
		end
	end
end