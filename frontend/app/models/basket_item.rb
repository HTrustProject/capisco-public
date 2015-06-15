# Item in the basked of pursuit (te kete-aronui), e.g., a user has requested
# to add a term to the knowledge base.
class BasketItem < ActiveRecord::Base
  # Proposed term
  validates :term, presence: true

  # Additional information provided by the user
  validates :comment, :default => nil

  # If set to true the item has been archived
  validates :archived, :default => false
end
