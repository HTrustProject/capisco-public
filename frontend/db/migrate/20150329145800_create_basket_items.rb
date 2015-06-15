class CreateBasketItems < ActiveRecord::Migration
  def change
    create_table :basket_items do |t|
      t.string :term
      t.text :comment
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end
