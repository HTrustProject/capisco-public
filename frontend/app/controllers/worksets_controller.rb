class WorksetsController < ApplicationController

## TODO: LATER NEED TO FIND AND DISPLAY WORKSETS BY USER ID

	def index
		@worksets = Workset.all
		
		# need to show worksets only for the current user		
		
		respond_to do |format|
			format.html		# show.html.erb
			format.json { render json: @worksets }
		end
	end

  	
	# show the basic workset information but also the search results in the workset
	# Could use the 'build' action to not save to the database
	# http://apidock.com/rails/ActiveRecord/Associations/CollectionProxy/build	 
  def show
		@workset = Workset.find(params[:id]) #Workset.find_by(name: params[:name])

		@storedresults = @workset.getSavedSearchResults()
		
		# For rendering json, we still return just the workset, because it's used in displaying the workset dropdown
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @workset }
      end
  	end
  	
	def new
       @workset = Workset.new	
       
       respond_to do |format|
         format.html
         format.json { render json: @worksets }
       end		
	end


	def edit
		@workset = Workset.find(params[:id])
	end

# http://stackoverflow.com/questions/2472393/rails-new-vs-create
# An HTTP GET to /resources/new is intended to render a form suitable for creating a new resource, which it  
# does by calling the new action within the controller, which creates a new unsaved record and renders the form.
# An HTTP POST to /resources takes the record created as part of the new action and passes it to the create 
# action within the controller, which then attempts to save it to the database.

	def create
##          render plain: params[:workset].inspect
          
          @workset = Workset.new(workset_params)

			 # For now, attach the new workset to the first user
			 # Later, get the user from the session. Once a workset has been opened, 
			 # the session should store it as the active workset for that user
			 # Alternatively, let the User model store activeWorkset as a member var
			 if @workset.users.count == 0
			 	user = User.new
			 	user.name = "Pinky"
			 	user.email = "pinky@paws.com"
			 	user.password = "pinky"
			 	user.save
			 end			 	
          user = User.find(1)
          @workset.users << user
          
          if @workset.save
            respond_to do |format|
              format.html { redirect_to worksets_path } # if none specified, go to show page of current workset. Here we reload worksets page
              format.json { render json: @workset }		
            end
          else
            render 'new' # what??? Need error message on same page preferrably
            # flash.now.alert = "Invalid values"
          end
        end
	
  def update
    @workset = Workset.find(params[:id])

	 if @workset.update(workset_params)
	 	respond_to do |format|
	      format.html { redirect_to @workset } # show
	      format.json { render json: @workset }
	   end
    else
      render 'edit'
    end
  end
  
  def destroy
    @workset = Workset.find(params[:id])
    @workset.destroy

    redirect_to worksets_path 
  end
  
	def deselect
		# get the search result to be deselected
		@workset = Workset.find(params[:id])
		@searchresult = @workset.searchresults.find_by_document_id(params[:docid]) # returned searchresult would be unique, not an array of searchresults
		
		# deselect it and mark the updated time
		@searchresult.selected = false
		@searchresult.date = DateTime.now
		
		# update in database
		@searchresult.save
		
		redirect_to workset_path(@workset) # redirect to this workset's #show page
	end
 	
 	# http://apidock.com/rails/ActionController/MimeResponds/InstanceMethods/respond_to
 	# http://stackoverflow.com/questions/1180807/ruby-on-rails-how-to-render-as-xml-models-with-has-many-associations
 	# http://stackoverflow.com/questions/5616086/rails-format-xml-render-and-pass-multiple-variables
 	# http://railscasts.com/episodes/362-exporting-csv-and-excel?view=asciicast
 	# http://api.rubyonrails.org/classes/ActionController/Renderers.html#method-c-add
	# http://stackoverflow.com/questions/8494255/converting-url-to-json-version
	def export
		@workset = Workset.find(params[:id])		
		
		# get the search results for this workset that were selected 
		@storedresults = @workset.getSavedSearchResults()
		
		respond_to do |format|
			format.xml # export.xml.builder
			format.csv { render :csv => @workset, :filename => @workset.title } # calls Workset.to_csv, see also config/initializers/csv_renderer.rb
			format.greenstonecsv { render :greenstonecsv => @workset, :filename => @workset.title } # calls Workset.to_greenstonecsv, see also config/initializers
			format.xls # export.xls.erb, see # http://railscasts.com/episodes/362-exporting-csv-and-excel?view=asciicast		
    	end
	end
	
	# Returns the senses in the workset, along with their frequencies
	def senseFrequencies
		@workset = Workset.find(params[:id])
		
		# http://stackoverflow.com/questions/14824453/rails-raw-sql-example
		# placeholders: http://stackoverflow.com/questions/15629051/raw-sql-insert-into-remote-ruby-on-rails-database
		sql = "select sense, count(sense) count from queryterms q "
		sql += "join documents_queryterms dq on q.id = dq.queryterm_id " 
		sql += "join documents d on d.id = dq.document_id "+ "join searchresults sr on d.id = sr.document_id "
				sql += "where sr.workset_id = " + @workset.id.to_s + " and sr.selected = 't'"
				sql += "group by sense "
				sql += "order by count(sense) desc"

		#sql = "select * from "
		#sql += " searchresults dq " 

		# http://stackoverflow.com/questions/14824453/rails-raw-sql-example
		# http://guides.rubyonrails.org/active_record_querying.html section 12.2.2
		
	   @records_array = ActiveRecord::Base.connection.execute(sql) # Workset.execute(sql).values()

	   data = []
	   for row in @records_array;
	   	data << {
	   		'sense'   => row[0],
	   		'count'   => row[1]
	   	}	   	
	   end
	   
	   graphData = [
	   	{
	   		'workset' => {
	   			'id' => @workset.id.to_s,
	   			'title' => @workset.title,
	   		},
	   		'data' => data
	   	}	
	   ]
		
		# http://stackoverflow.com/questions/6345383/how-to-create-complex-json-response-in-ruby-in-rails
		respond_to do |format|
			format.json { render json: graphData } # calls as_json 
		end
	end

# NEED TO CHECK WITH ANDREW
#Can't verify CSRF token authenticity
#The count is: 2
#here is @senseTerms:
#Emu
#Kiwi
#[["Emu","Kiwi"],["Emu"],["Kiwi"]]
#Executing query: set /lucene/docID true
	
  def saveSearchResults
    
    @workset = Workset.find(params[:id])

    if params[:queryresults] != nil # if there are were no search results, this could be nil    
    	 @queryresults = params[:queryresults]
    	 	
	    @queryresults.each_with_index do |result, index|
	      
	      # array indexes are strings, since we're stuck with strong parameters 
	      # and can't use JSON.parse on params[:param]
	      
	      #puts "@@@ Saving searchresult : " + @queryresults[index.to_s].to_s
	      queryresult = @queryresults[index.to_s]
	      docid = saveSearchResult(queryresult)
	      #puts "@@@ Saved with docid " + docid.to_s
	      
	    end
	 end
	 
    respond_to do |format|
      format.json { render json: @workset }
    end

  end


	# http://stackoverflow.com/questions/7297338/how-to-add-records-to-has-many-through-association-in-rails
   # http://guides.rubyonrails.org/active_record_querying.html
   # http://ruby-journal.com/graceful-fallback-for-not-found-activerecord-lookup-with-nullobject-pattern/
   # https://hackhands.com/building-has_many-model-relationship-form-cocoon/          	
  	def saveSearchResult(result)
          
       #result = result[0]

       @workset = Workset.find(params[:id]) #Workset.find_by(name: params[:name])
       
       # find_by returns the first match, but internalid and sourceid should be unique, so we expect only 1 result
       document = Document.find_by(internalid: result["internalid"]) # OR FIND_BY sourceid?
       
       new_searchresult = false  # keep track of whether the searchresult (not document) is new      
       
       if document 
         # document exists in documents table
			# what if the document exists in another workset but not in this one?          	
         
         # update document? check fields are still up to date?
         # do whatever            
         document.sourceid = result["sourceid"] # update title and source id?
         document.title = result["title"]           
         document.save
         
         # see whether the existing document is part of this workset
         # if not, create a searchresult, which will associate this workset with the document 
         
         # find always causes an exception when the ID can't be found. 
         # And we expect that IDs might not be found in the following
         # http://stackoverflow.com/questions/9709659/rails-find-getting-activerecordrecordnotfound
         # http://old.blog.phusion.nl/2013/01/03/rails-sql-injection-vulnerability-hold-your-horses-here-are-the-facts/
         
         @doc = @workset.documents.find_by_id(document.id)
         
         if @doc.nil? 	# the document exists but is not part of this workset
           # add it to this workset. The << will update the join table
           @workset.documents << document			
           new_searchresult = true # new searchresult for existing document					
         else
           new_searchresult = false # we're updating existing searchresult (for a document already in this workset)					 
         end
         
         # now the doc is definitely in the workset. Update the searchresult join table with whether the doc was selected and current time				
         
       else # create new document
         #document = Document.create(search_result_params) #params[:internalid], params[:sourceid], params[:title])
         
         document = Document.new #params[:internalid], params[:sourceid], params[:title])
         document.internalid = result["internalid"]
         document.sourceid = result["sourceid"]
         document.title = result["title"]
         
         @workset.documents << document
         new_searchresult = true # new searchresult for new document				
       end    
       
       # the << operator used above will have built the join (searchresult) for us, so can get the search result now:
       # http://stackoverflow.com/questions/7297338/how-to-add-records-to-has-many-through-association-in-rails      
       
       # Save the searchresult iff either the user has specifically selected a doc that already exists in this workset, or if it's a new searchresult
       # But don't save the searchresult if the doc already existed in this workset (not a new searchresult) but the doc was left unselected this time: 
       # don't want to overwrite previous selection status of the doc in that case
       if new_searchresult || result["selected"] == "true" # params are strings not boolean! So if (params[:selected]) will always return true, 
         # even if its value is "false". Therefore, do a string comparison against "true" 
         @searchresult = @workset.searchresults.find_by_document_id(document.id) # alt: @workset.searchresults.find_by(:document_id => document.id)
         @searchresult.selected = result["selected"]
         @searchresult.date = DateTime.now
         @searchresult.save			 	
         #else
         #puts "@@@@ Not touching searchresult for document " + document.id.to_s + " " + params[:internalid].to_s
       end
       
		 document.associateQueryterm(result["querytermids"])	       
       
       return document.id
     end
		  
  
  private
  def workset_params
    params.require(:workset).permit(:title, :description)
  end
  
	# http://stackoverflow.com/questions/18436741/rails-4-strong-parameters-nested-objects
  def search_result_params
    #params.require(:searchresult).permit(:internalid, :sourceid, :title, :isselected)
    params.permit(:internalid, :sourceid, :title)
  end

#  def workset_results_params
#    params.require(:queryresults).permit({:internalid, :sourceid, :title, :selected, :queryterms => [{:sense, :term, :termnum, :senseid}]})
#  end
  	
end
