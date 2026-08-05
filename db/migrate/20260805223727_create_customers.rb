class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.boolean :has_payment_method

      t.timestamps
    end
    add_index :customers, :email, unique: true
  end
end
