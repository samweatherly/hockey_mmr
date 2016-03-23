class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :home_name
      t.integer :home_goals
      t.float :home_mmr
      t.integer :home_k
      t.references :home_team
      t.string :away_name
      t.integer :away_goals
      t.float :away_mmr
      t.integer :away_k
      t.references :away_team
      t.date :date
      t.string :extra_time
      t.float :home_rating_change
      t.float :away_rating_change
      t.boolean :playoff

      t.timestamps null: false
    end
  end
end
