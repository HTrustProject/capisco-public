class QuerytermsController < ApplicationController

	def index
		@queryterms = Queryterm.all
		
		respond_to do |format|
			#format.html		# show.html.erb
			format.json { render json: @queryterms }
		end
	end
		
	def show
		@queryterm = Queryterm.find(params[:id])   
		respond_to do |format|
			#format.html
			format.json { render json: @queryterm }
		end
  	end
  	
  	def new
  	end
  	
	def create
		@queryterm = Queryterm.new(queryterm_params)
		 
		@queryterm.save! # produces error on fail
		#if @queryterm.save!
		#	return @queryterm.id
		#else
		#  return -1
		#end            
	end
	
	def update
		@queryterm = Queryterm.find(params[:id])

	 	if @queryterm.update(queryterm_params)
	 		respond_to do |format|
	      	#format.html { redirect_to @queryterm } # show
	      	format.json { render json: @queryterm }
	   	end
    	else
	      render 'edit'
   	end              
	end
	
	def saveQueryterms
		@queryterms = params[:queryterms]
		
		@queryterm_ids = []		
		
		@queryterms.each_with_index do |term, index|
            
         # array indexes are strings, since we're stuck with strong parameters 
         # and can't use JSON.parse on params[:param]
         
         #puts "@@@ saving queryterm : " + @queryterms[index.to_s].to_s         
         queryterm_record = @queryterms[index.to_s]
			id = save(queryterm_record)
			@queryterm_ids.push(id)
		end	
	
		respond_to do |format|
      	format.json { render json: @queryterm_ids }
	   end
	end

	# add a new query term if it doesn't already exist
	# if it does, return its id
  def save(qterm)   
    #@queryterm = Queryterm.new(qterm) #Queryterm.new(:queryterm => qterm)		 
    @queryterm = Queryterm.new #Queryterm.new(:queryterm => qterm)
    @queryterm.sense = qterm["sense"]
    @queryterm.senseid = qterm["senseid"]
    @queryterm.term = qterm["term"]
    @queryterm.termnum = qterm["termnum"]
    
    # get all the queryterms with the given term+termnum+sense combination (senseid numbering might change?)
    # since no field except the auto id primary key is unique to the queryterms table
    
    # http://stackoverflow.com/questions/9650205/rails-find-all-with-conditions
    # http://stackoverflow.com/questions/16244411/rails-where-clause-for-associations		
    
    
    @querytermsForSense = Queryterm.where(sense: @queryterm.sense, term: @queryterm.term, termnum: @queryterm.termnum).all # or .to_a instead of .all
    # there shouldn't be more than one, since we don't save a queryterm with duplicate values
    
    # Following didn't work, since the parameters weren't accepted, so create a new queryterm first, then only save it if it doesn't exist
    #@querytermsForSense = Queryterm.where(:sense => qterm["sense"], :term => qterm["term"], :termnum => qterm["termnum"]).all
    #@querytermsForSense = Queryterm.where(sense: qterm["sense"], term: qterm["term"], termnum: qterm["termnum"]).all
				
    
    resultid = -1		
    
    if @querytermsForSense.empty?
      # save the new queryterm to table		 	
      @queryterm.save!
      resultid = @queryterm.id 
    else		 
      # discard the new queryterm created
      # update senseid?
      resultid = @querytermsForSense[0].id # id of first result 
      
    end
    return resultid
  end

 	
  	private
	# http://patshaughnessy.net/2014/6/16/a-rule-of-thumb-for-strong-parameters  	
  	#def queryterms_params
  		##params.require(:queryterms).permit( {[:senseid, :sense, :term, :termnum] } )
  		##params.permit( { queryterms: [:senseid, :sense, :term, :termnum] } )
  		#params.permit( { queryterm: [:senseid, :sense, :term, :termnum] } )
  	#end
  	
	# http://stackoverflow.com/questions/18436741/rails-4-strong-parameters-nested-objects
	# http://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit	
	def queryterm_params	
		params.require(:queryterm).permit(:senseid, :sense, :term, :termnum)		
		#params.permit(:senseid, :sense, :term, :termnum)
		#params.permit("senseid", "sense", "term", "termnum")
	end
	
end
