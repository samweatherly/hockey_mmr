class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.float :mmr
      t.integer :k_value
      t.float :home_mmr
      t.float :away_mmr
      t.string :logo
      t.boolean :active

      t.timestamps null: false
    end
  end
end
