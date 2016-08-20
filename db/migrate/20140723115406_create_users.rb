class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :api_token
      t.string :api_secret

      t.timestamps
    end
  end
end
