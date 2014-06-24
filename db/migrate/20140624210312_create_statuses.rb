class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :user_name
      t.string :password

      t.timestamps
    end
  end
end
