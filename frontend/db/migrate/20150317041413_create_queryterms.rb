class CreateQueryterms < ActiveRecord::Migration
  def change
    create_table :queryterms do |t|
      t.integer :senseid
      t.string :sense
      t.string :term
      t.integer :termnum

      t.timestamps
    end
  end
end
