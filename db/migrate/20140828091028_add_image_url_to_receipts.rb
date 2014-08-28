class AddImageUrlToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :image_url, :string
  end
end
