class Link
  include ActiveAttr::AttributeDefaults

  attribute :symbol, :default => nil
  attribute :concept, :default => nil
  attribute :context, :default => nil
  
end