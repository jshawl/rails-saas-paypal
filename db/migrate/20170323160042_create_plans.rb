class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.string :title
      t.string :description
      t.float :price
    end
  end
end
