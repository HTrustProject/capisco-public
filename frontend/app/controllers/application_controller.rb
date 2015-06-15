class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by returning a null session
  protect_from_forgery with: :null_session
  
  include KnowledgeBaseHelper
  
  def stringToBool(string)
    if string != nil
      return ["True", "true", "1"].include?(string)
    else
      return false
    end
  end
end
