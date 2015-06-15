class Searchresult < ActiveRecord::Base
	belongs_to :workset # workset_id
	belongs_to :document # document_id
end
