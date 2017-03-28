class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.string :title
      t.string :description
      t.float :price
      t.string :paypal_button_id
    end
  end
end
