class RemoveAttachmentImageToReceipts < ActiveRecord::Migration
  def self.up
    remove_attachment :receipts, :image
  end

  def self.down
    add_attachment :receipts, :image
  end
end
