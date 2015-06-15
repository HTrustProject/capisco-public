class Document < ActiveRecord::Base
	has_many :searchresults	
	has_many :worksets, through: :searchresults
	
	# the same document can appear for many different query terms
	# and the same query_term can lead to many different documents 
	has_and_belongs_to_many :queryterms
	
	# returns this document's sourceid converted to a URL  
	# the same way as is done in views/search_results/results.html.erb	
	def getURL
		linkparts = sourceid.split(" "); 
      doc_identifier = linkparts[0];
      page_identifier = linkparts[1].gsub(/^[0]+/, ''); # remove leading zeroes from pagenum
      doc_identifier = doc_identifier.gsub("+",":").gsub("=","/");
		link = "http://babel.hathitrust.org/cgi/pt?id=" + doc_identifier + ";view=1up;seq=" + page_identifier;
		return link
	end

	def getPagenum
		page_id = sourceid.split(" ")[1].gsub(/^[0]+/, ''); # remove leading zeroes from pagenum
		return page_id
	end
	
	# given the id of queryterms already in the database, associate them with this document
	# the queryterms already exist, but so does the document: we call this function on the document passing in the queryterm_ids
        # http://stackoverflow.com/questions/26665494/activerecord-how-to-add-existing-record-to-association-in-has-many-through-rela
        # http://apidock.com/rails/ActiveRecord/Associations/CollectionProxy/build
	def associateQueryterm(queryids) #WithDocument
	
		@document = self # this document

		#puts "@@@@ Trying to associate with " + queryids.to_s

		queryids.each do |qid_str|
			queryid = qid_str.to_i
			@queryterm = @document.queryterms.find_by_id(queryid) # @document.queryterms.find(queryid) # throws RecordNotFound exception if not found
			        
			if @queryterm.nil?           
				#puts "@@@@ COULDN'T FIND QUERY TERM ID WITH DOC ID: " + qid_str + " " + @document.id.to_s
	
				# associate the document with the queryterm 
				# unless @document # if not already the case, then
				@document.queryterms << Queryterm.find(queryid) # create the association between Doc and Queryterm in the join table				
			#else 
				#puts "@@@@ QUERY TERM ID ALREADY ASSOCIATED WITH DOC ID: " +  qid_str + " " + @document.id.to_s
			end
		end
		
	end
	
end
