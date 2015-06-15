class CreateDocumentsQuerytermsJoinTable < ActiveRecord::Migration
	# when you reference the ":document" the rails systems seems to automatically reference the "document_id" field.
	# http://stackoverflow.com/questions/6561330/rails-3-has-and-belongs-to-many-migration
	# that page also shows you can change the order of the indexed keys document_id and queryterm_id 

	def change
		create_table :documents_queryterms, id: false do |t|
      	t.belongs_to :document, index: true # adds document_id
      	t.belongs_to :queryterm, index: true # adds queryterm_id
   	end
	end
end
