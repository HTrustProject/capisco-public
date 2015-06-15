require 'csv'
#require 'cgi' # for encoding and decoding URL-specific html entities, see http://stackoverflow.com/questions/1600526/how-do-i-encode-decode-html-entities-in-ruby

class Workset < ActiveRecord::Base

	# no dependent: :destroy for has_and_belongs_to_many http://stackoverflow.com/questions/2799746/habtm-relationship-does-not-support-dependent-option
	# which explains that RoR 4.2.0 handles deletions in has and belongs to many assocations, which seems to work when I tested delete on a workset
	
	has_and_belongs_to_many :users
	
	has_many :searchresults	
	has_many :documents, through: :searchresults

	validates :title, presence: true, length: { minimum: 1 }
#	validates :description, presence: true
	
	# http://railscasts.com/episodes/362-exporting-csv-and-excel?view=asciicast
	# http://stackoverflow.com/questions/2472694/generate-csv-file-from-rails
	# http://stackoverflow.com/questions/5182344/rails-3-how-to-respond-with-csv-without-having-a-template-file
	# http://api.rubyonrails.org/classes/ActionController/Renderers.html#method-c-add	
	def to_csv	
		storedresults = getSavedSearchResults
		
		csv_string = CSV.generate do |csv|			  
			csv << ["Date", "Search Term info", "Title", "Pagenum"] # col_headings ## %w[fieldname1, fieldname2]
			
			storedresults.each do |searchresult|
				csv << [searchresult.date, searchresult.searchterminfo, searchresult.title, searchresult.pagenum]
				
			end
		end
		return csv_string
		
	end
	
	# generates a csv file containing ex.weblink metadata fields for Greenstone to process with CSVPlugin
	# Each record (row of csv values) of such a csv file represents a single document in Greenstone
	# With weblink metadata, the source document is not necessary and greenstone will just link to the source document	 
	# http://stackoverflow.com/questions/1600526/how-do-i-encode-decode-html-entities-in-ruby
	# the searchterminfo field can contain commas, see http://stackoverflow.com/questions/769621/dealing-with-commas-in-a-csv-file
	# "Fields containing line breaks (CRLF), double quotes, and commas should be enclosed in double-quotes."
	# However, Rails' CSV class seems to take care of that already: titles with commas get double-quoted already 
	def to_greenstonecsv	
		storedresults = getSavedSearchResults
		
		csv_string = CSV.generate do |csv|			  
			csv << ["dc.Date", "dc.Subject and Keywords", "Title", "URL", "Identifier", "Pagenum", "weblink", "webicon", "/weblink"] # no dc prefix means ex.* prefix
			
			storedresults.each do |searchresult|				
				#entityEncodedURL = CGI.escapeHTML("<a href=\""+searchresult.url+"\">")
				entityEncodedURL = "<a href='"+searchresult.url+"'>" #"<a href=\""+searchresult.url+"\">"
				closeURL = "</a>" #closeURL = "&lt;/a&gt"
				csv << [searchresult.date, searchresult.searchterminfo, searchresult.title, searchresult.url, searchresult.sourceid,
					searchresult.pagenum, entityEncodedURL, "_iconworld_",  closeURL]
				
			end
		end
		return csv_string
		
	end	
	
  	def getSavedSearchResults()
		@workset = self # this workset
		
		# we'll display only the search results of *this* workset that were marked as selected, ordered by date
		# http://guides.rubyonrails.org/active_record_querying.html				
		selected_searchresults = @workset.searchresults.where(selected: true).order(:date).all; # alt syntax: where(:selected => false).all;  	
  	
		# Create a structure with a name under Struct
		# http://ruby-doc.org/core-2.2.0/Struct.html

		# term information struct to allow sorting by termnum, to reproduce the search terms in the sequence users entered it
		# classes and structs can be sorted. We sort the queryterms by the termnum field
		# http://stackoverflow.com/questions/2870104/sorting-an-array-of-structs
		# Struct.new("TermInfo", :sense, :term, :termnum)
		# terminfos.sort {| a, b | a[:termnum] <=> b[:termnum] } 
		
		Struct.new("StoredResult", :date, :searchterminfo, :title, :url, :pagenum, :sourceid, :docid)
		@storedresults = []
		
				         
		selected_searchresults.each do |searchresult|
			
			document = Document.find(searchresult.document_id)
			url = document.getURL # converts sourceid field into url
			pagenum = document.getPagenum 			
			title = document.title
			
			# get the queryterms which returned this document, sorted by the order in which the search terms were entered
			# http://stackoverflow.com/questions/16456341/sort-in-ascending-order-rails 
			queryterms = document.queryterms.order(:termnum)
			
			# display the queryterms associated with this doc in the form: 
			# 'sense1 ("term1"), sense2 (term2) ...', which will be in termnum sequence 			
			termInfoLine = ""
			queryterms.each do |queryterm|				
				termInfoLine += queryterm.displaySenseTerm + ", "
			end
			termInfoLine = termInfoLine.chomp(", ") # remove extra comma at end
			
			
			result = Struct::StoredResult.new(searchresult.date, termInfoLine, title, url, pagenum, document.sourceid, searchresult.document_id)
			@storedresults.push(result)
		end
		return @storedresults
		
  	end	
	
end
