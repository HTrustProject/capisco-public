class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :sourceid
      t.integer :internalid
      t.string :title
      t.text :resultlines

      t.timestamps
    end
  end
end
