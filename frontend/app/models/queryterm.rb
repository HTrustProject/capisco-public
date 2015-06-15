class Queryterm < ActiveRecord::Base
	has_and_belongs_to_many :documents
	
	# displays this queryterm in the form: 'sense1 ("term1")'
	def displaySenseTerm
		return sense + " ('" + term + "')"		
	end	
	
end
