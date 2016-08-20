class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.string :filename
      t.string :md5_digest
      t.integer :totalLines
      t.string :accuracy
      t.text :lines

      t.timestamps
    end
  end
end
