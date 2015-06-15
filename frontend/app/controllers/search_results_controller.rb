# This is the controller for the search results page, seen after the
# user clicks GetDocs

require 'json'

class SearchResultsController < ApplicationController


  def show
    socket = TCPSocket.open @@address, @@port
    
    if params[:terms] != nil
      @terms = params[:terms]
      @results = getDocuments(@terms, socket);
    end
    
    respond_to do |format|
      # Todo: update the show page, to look like the old search_results/results, but at searchresults/show
      # format.html
      format.json { render :json => @params }
    end
  end  

	def returnMetadataAJSON

          metadata_hash = Hash["title" => "Unknown"]
          
          if params[:docid] != nil
            require 'open-uri'
            require 'uri'
            require 'rexml/document'
            
            docid = params[:docid]
            puts "the docNum is: " + docid
                        
            # following URL previously used title_ab
            htrc_url = "http://chinkapin.pti.indiana.edu:9994/solr/meta/select?q=id:"+URI.escape(docid)+"&fl=title_top"
            
            file = open(htrc_url)

            xml_str = file.read
            xml_doc = REXML::Document.new(xml_str)
            
            title_metadata = REXML::XPath.first(xml_doc, "//doc/arr/str/text()")
            
            metadata_hash["title"] = "" + title_metadata.to_s
          end

          respond_to do |format|
            format.html
            format.json { render json: metadata_hash }
          end
        end


	def results

		@senseCount = 0
		@outlinkCount = 0
		@senseGetString = ""          
    	@combinationsArrayGetString = ""

		require 'socket'
		s = TCPSocket.open @@address, @@port

		if params[:senseTerms] != nil
			@terms = JSON.parse(params[:termInfos])
         #@senseTerms = @terms.collect { |(termnum, term, sense)| sense } # works, but venn diagram fails because params[:senseTerms] is missing
			@senseTerms = JSON.parse(params[:senseTerms])
			@senseCount = @senseTerms.count
			

			# A term record looks like: { termnum => "...", term => "...", sense => "...", senseid => "..." }
                  #also want a hashmap of the term information indexed by sense
                  @senseMap = {}
                  @terms.each do |term|
              key= term["sense"]
              @senseMap[key] = {:termnum => term["termnum"], :term => term["term"], :senseid => term["senseid"] }
			end      
                  

			puts "The count is: " + @senseCount.to_s
			puts "here is @senseTerms:"
			puts @senseTerms
			
			#puts "here is terms:"
			#puts @terms
			#puts "here is @senseids:"
			#puts @senseids
                  
                  puts params[:combinationTerms]

                  @combinationTerms = JSON.parse(params[:combinationTerms])

                  senseGetDocResults = Hash.new
                  @senseResults = Hash.new
                  @combinationsAsString = [] # storing the 'keys' in an array in the order they came in

                  # loop through the combinationTerms array, creating the hashmaps of the doc results for each combination
                  for combination in @combinationTerms do
                    key = combination.join('|')

                    # now key is something like Kiwi|Cow|Wellington
                    senseGetDocResults[key] = getDocumentIdList(key, s)
                    @senseResults[key] = getDocuments(combination, s); 
                            # combination is an array of Terms, a single combination (combinationTerms is an array of arrays of terms: all combinations of the terms)


                    # store the keys in an arrays, organised by the order the combinations came in
                    @combinationsAsString.append(key) # e.g. Cow|Kiwi|Wellington
                  end
                  
                end

          # make the combinationsAsString array available for the returnAJSON action
          @combinationsArrayGetString.gsub!("|", "_")

          # outlinks code left as before
		if params[:outlinkTerms] != nil
			@outlinkTerms = JSON.parse(params[:outlinkTerms])
			@outlinkCount = @outlinkTerms.count
		end

		puts "outlinks Count: " + @outlinkCount.to_s
		puts "Outlink Terms: " + @outlinkTerms.inspect

		# Outlinks are still here, however displaying these is optional and maybe buggy
          @outlinkArray1 = []
          @outlinkArray2 = []
          @outlinkArray3 = []
          @outlinkArray4 = []

		if @outlinkCount >= 4
			outlink4 = @outlinkTerms[3]

			docsList = getDocumentIdList(outlink4, s)
			for r in getDocuments([outlink4], s)
				@outlinkArray4.push r
			end
		end 

		if @outlinkCount >= 3
			outlink3 = @outlinkTerms[2]

			docsList = getDocumentIdList(outlink3, s)
			for r in getDocuments([outlink3], s)
				@outlinkArray3.push r
			end
		end

		if @outlinkCount >= 2
			outlink2 = @outlinkTerms[1]

			docsList = getDocumentIdList(outlink2, s)
			for r in getDocuments([outlink2], s)
				@outlinkArray2.push r
			end
		end

		if @outlinkCount >= 1
			outlink1 = @outlinkTerms[0]

			docsList = getDocumentIdList(outlink1, s)
			for r in getDocuments([outlink1], s)
				@outlinkArray1.push r
			end
		end

		s.close
	end

	def returnAJSON
		# This returns a JSON object for the Venn diagram

          ## shouldn't the member vars (instance vars) senseTerms and combinationTerms already exist?
          ## maybe not: each action is its own restful URL?

		@senseTerms = []
		@combinationsAsString = []

		if params[:senseTerms] != nil
                  @senseTerms = params[:senseTerms]
		end

		if params[:combinations] != nil
                  @combinationsAsString = params[:combinations]

                  #@combinationsAsString.map! { |x| x.gsub!("_", "|") } # didn't work, empty final element
                  for combination in @combinationsAsString do
                    combination.gsub!("_", "|")
                  end
		end

		require 'socket'
		s = TCPSocket.new @@address, @@port


		puts @senseTerms
		puts @senseTerms[0]

          
          # going to build a jsonstring of the form:
          # {"data": {"AB": 0
          # ,"A": 58
          # ,"B": 1
          # },"legend": {"A": "Cow-calf","B": "Kiwifruit"}}
          #
          # where A: 58 means 58 docs on Cow-calf, 
          # and AB: 0 means 0 docs containing both Cow-calf and Kiwifruit

          # Have @combinationsAsString of the form [Cow-calf|Kiwifruit, Cow-calf, Kiwifruit]
          # So now need to generate [AB, A, B] from this

          # First, create an alphabetic range and turn it into an array
          # then truncate this to the size of the number of senseTerms, 
          # one letter per senseTerm
          # https://thenewcircle.com/static/bookshelf/ruby_tutorial/ranges.html

          alphaArray = ("A".."Z").to_a # [A, B, C, .. Z]          
          #alphaArray = alphaArray[0..@senseTerms.count-1] # e.g. A, B, C

          if (@senseTerms.length > alphaArray.length) 
            puts "@@@@ WARNING: sense terms exceeds number of letters in alphabet."
            puts "@@@@ Unable to assign a letter to each sense."
          end

          # create a map from sense to letter
          alphaMap = Hash.new
          i = 0
          for sense in @senseTerms do
            alphaMap[sense] = alphaArray[i]
            i += 1
          end

          # map from letter to sense
          reverseAlphaMap = alphaMap.invert
          

          # create a new combinationsAsString array, but where each
          # each sense term is replaced with its corresponding letter
          # e.g. [Cow-calf|Kiwifruit, Cow-calf, Kiwifruit] => [A|B, A, B]
          alphaCombinations = Array.new(@combinationsAsString.length)
	
			 # sort the senses string array in descending string length order (longest to shortest sense)
			 # so that we replace the sense "Kiwifruit" before replacing the sense "Kiwi", else we would 
			 # have ended up with lots of dangling *fruit instances
			 # http://stackoverflow.com/questions/2642182/sorting-an-array-in-descending-order-in-ruby
			 senseTermsSortedByLength = @senseTerms.sort_by {|combination| combination.length}.reverse
          
          @combinationsAsString.each_with_index do |combination, i|
            str = combination # e.g. str = Cow|Kiwi|Wellington 

            # the sense components of combinations are stored sorted alphabetically, 
            # but the senseTerms array has also been stored sorted alphabetically

            for sense in senseTermsSortedByLength do
              str = str.gsub(sense, alphaMap[sense]) # substituting the sense with its letter
            end

            # now we have something like str=A|B|C|D, store as is
            alphaCombinations[i] = str
            
            i += 1
          end

          # create a map of the letterCombinations (of the sense-combinations) 
          # and the docCounts for those combinations
          # This is a batch request, and returns counts for all requested combinations
          delimiter = ","
          counts = getDocCountsForAllCombinations(@combinationsAsString, delimiter, s)
          #puts "@@@@@ DOC COUNTS: " + counts
          counts = counts.split(delimiter)          
          
          # create an array of all the counts minus their intersections (i.e. total for term A should be minus its intersections with any other term)
			 countsWithoutIntersectionArray = getCountsWithoutIntersection(alphaCombinations, counts)
          
          combinationCounts = Hash.new
          i = 0
          for combination in alphaCombinations do # in for c in @combinationsAsString
            #combinationCounts[combination] = counts[i] # strings
            combinationCounts[combination] = countsWithoutIntersectionArray[i].to_s #integers need to be converted to strings 
            i += 1
          end          

          # can now construct the response
          newJsonString = '{"data": {'

          for combination in alphaCombinations do
            # first, for each combination like A|B|C|D, construct "ABCD: "
            newJsonString = newJsonString + "\"" + combination.gsub("|", "") + "\": " 
            # for ABCD, would need to get the doc count for each of the 4 senses 
            # that map to ABCD. So first need to create an array of matching senses

            letters = combination.split("|")
            senses = Array.new(letters.length)
            i = 0
            for letter in letters do
              senses[i] = reverseAlphaMap[letter]
              i += 1
            end

            # secondly, the JSON object needs to store the total document count 
            # for all the individual senses in that combination

            # the OLD WAY: contact wmi for each combination to get its count
            #newJsonString = newJsonString + getDocumentCounts(senses, s) + ','

            # the NEW WAY: we've already contacted wmi with a batch request to
            # get the counts for the combinations, now just add them to the JSON
            newJsonString = newJsonString + combinationCounts[combination].to_s + ','

          end

          newJsonString = newJsonString[0..-2] # remove comma and newline at end

          newJsonString += '},"legend": {'

          for sense in @senseTerms
            letter = alphaMap[sense]
            newJsonString = newJsonString + "\"" + letter + "\": \"" + sense + '",'
          end

          newJsonString = newJsonString[0..-2]
          newJsonString +='}}'
          
          parsed = JSON.parse(newJsonString)
          
          respond_to do |format|
            format.html
            format.json { render json: parsed }
          end

          #puts "#### newJSONstring: " + newJsonString

        end # end action/function definition

	private
	
		def getCountsWithoutIntersection(letterCombinations, countsAtCombinations)
		
			a = Array.new(countsAtCombinations.length) # the array of counts without the count for the intersections
			alphaCombinations = Array.new(letterCombinations.length)
			
			# 1. make a copy of countsAtCombinations. 
			# We'll also make sure the values are not strings anymore, but numbers
			countsAtCombinations.each_with_index do |count, index| # http://stackoverflow.com/questions/4811668/rails-get-index-of-each-loop
				a[index] = count.to_i
				alphaCombinations[index] = letterCombinations[index].gsub("|","")
			end
			
			# the first=maximum-combination has the correct count, subsequent counts are reduced by previous cumulative/running-total counts
			current = 1			
			while(current < a.length) # loop from start to end of array a, filling in the right counts at each current index  
				
				# starting from the first combination, look at all previous combinations before current index,  
				# subtracting their counts from the current one IF APPLICABLE
				 
				prev = 0; 
				while(prev < current)  # look at all the combinations/counts before the current
					
					# the previous combination must be longer, e.g. ABCD > ABD is right, but ABC==ABD is not right
					# and all letters in the current alphacombination must occur in the previous. E.g. curr=AB and prev=ABD is right, but curr=AC and prev=ABD is wrong
					if alphaCombinations[prev].length > alphaCombinations[current].length && allLettersMustOccur(alphaCombinations[current], alphaCombinations[prev])
					
						# if the above conditions hold, then the array count at the current index needs to remove the intersectio denoted by the count at previous 
						# The array count at all prev indices will already have been calculated correctly, to contain their counts minus all their intersections
						
						a[current] -= a[prev]
					end

					prev += 1 # consider the next combination before the current					
				end
				
				current += 1 # finished calculating the count without intersection at the current index, advance to calculating the next
			end			
			
			return a # return the new counts array: the counts without intersection-counts			
		end

		# helper function for getCountsWithoutIntersection() which checks that each letter in substr occurs in str 
		# (returns false if any letter in substr does not occur) 
		def allLettersMustOccur(substr, str)
		
			# check all letters in substr occur in str
			i = 0
			while i < substr.length
				letter = substr.at(i)
				if str.exclude? letter
					return false
				end
				i = i+1
			end
			return true
		end

 end # end class
      


##end

