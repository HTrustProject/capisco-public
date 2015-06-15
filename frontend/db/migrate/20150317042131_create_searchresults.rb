class CreateSearchresults < ActiveRecord::Migration
  def change
    create_table :searchresults do |t|
    	t.belongs_to :workset, index: true
      t.belongs_to :document, index: true
      
      t.timestamp :date
      t.boolean :selected

      t.timestamps
    end
  end
end
