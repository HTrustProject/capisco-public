class Concept
  include ActiveAttr::Model
  
  attribute :id, :default => nil
  attribute :name, :default => nil
  attribute :description, :default => nil
end