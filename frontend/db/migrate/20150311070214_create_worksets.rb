class CreateWorksets < ActiveRecord::Migration
  def change
    create_table :worksets do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
