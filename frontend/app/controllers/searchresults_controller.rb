# This class might not be used
class SearchresultsController < ApplicationController

	def index
		@searchresults = SearchResult.all		
		respond_to do |format|
			format.html		# show.html.erb
			format.json { render json: @searchresults }
		end
	end
  
  def new
  end

	def create
		@searchresult = Searchresult.new(searchresult_params)       
      @searchresult.save! # produces error on fail

	end
	
	def update
		@searchresult = Searchresult.find_by_document_id(params[:documentid])
		searchresult.date = DateTime.now
	 	@searchresult.update!(searchresult_params)
	end
	
	
  	private	
	def searchresult_params		
		params.permit(:selected)
	end

end
