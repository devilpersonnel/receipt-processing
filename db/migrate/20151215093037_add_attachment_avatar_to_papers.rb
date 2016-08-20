class AddAttachmentAvatarToPapers < ActiveRecord::Migration
  def self.up
    change_table :papers do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :papers, :avatar
  end
end
