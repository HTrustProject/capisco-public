class CreateUsersWorksetsJoinTable < ActiveRecord::Migration
	def change
	   create_table :users_worksets, id: false do |t|
      t.integer :user_id
      t.integer :workset_id
    end
 
    add_index :users_worksets, :user_id
    add_index :users_worksets, :workset_id  
	end
end
