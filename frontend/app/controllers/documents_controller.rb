class DocumentsController < ApplicationController

	def index
		@documents = Document.all
		
		respond_to do |format|
			#format.html		# show.html.erb
			format.json { render json: @documents }
		end
	end
		
	def show
		@document = Document.find(params[:id])   
		respond_to do |format|
			f#ormat.html
			format.json { render json: @document }
		end
  	end
  	
  	def new
  	end
  	
	def create
		@document = Document.new(document_params)
       
       @document.save! # produces error on fail
       #if @document.save!
       #	return @document.id
       #else
       #  return -1
       #end
              
	end
	
	def update
		@document = Document.find(params[:id])

	 	if @document.update(document_params)
	 		respond_to do |format|
	      	#format.html { redirect_to @document } # show
	      	format.json { render json: @document }
	   	end
    	else
	      render 'edit'
   	end              
	end
  	
  	private
	# http://stackoverflow.com/questions/18436741/rails-4-strong-parameters-nested-objects
	# http://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
	def document_params
		#params.require(:searchresult).permit(:internalid, :sourceid, :title)
		params.permit(:internalid, :sourceid, :title)
	end
end