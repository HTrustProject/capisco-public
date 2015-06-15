class UsersController < ApplicationController

	def index
		@users = User.all
	end

  	def show
      @user = User.find(params[:id])  
  	end


	def new	
		@user = User.new
	end

   def edit
   	@user = User.find(params[:id])
   end

	def create
          
       @user = User.new(user_params)
       
       if @user.save
         redirect_to @user
       else
         render 'new'
       end

	end

	def update
	   @user = User.find(params[:id])
	
		if @user.update(user_params)
			redirect_to @user # show	   
	   else
	      render 'edit'
	   end
	end
	
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    redirect_to users_path 
  end

# http://stackoverflow.com/questions/2472393/rails-new-vs-create
# An HTTP GET to /resources/new is intended to render a form suitable for creating a new resource, which it  
# does by calling the new action within the controller, which creates a new unsaved record and renders the form.
# An HTTP POST to /resources takes the record created as part of the new action and passes it to the create 
# action within the controller, which then attempts to save it to the database.
	
	def createOLD
		# render plain: params[:user].inspect
  		
		@user = User.new(user_params)  #@user = User.create(user_params) #@user = User.new(params[:user]) 
  		@user.save
  		redirect_to @user

# http://www.millwoodonline.co.uk/blog/using-hassecurepassword-for-rails-authentication
  		
#  		user = User.find_by_email(params[:email])
#  		if user && user.authenticate(params[:password])
#    		session[:user_id] = user.id
#    		redirect_to admin_root_path, :notice => "Welcome back, #{user.email}"
#  		else
#    		flash.now.alert = "Invalid email or password"
#    		render "new"
#  		end
  		
	end

	private

	# strong params
	# replaces
	#  attr_accessible :name, :email, :password, :password_confirmation
	def user_params
		params.require(:user).permit(:name, :email, :password)
	end
  
end
