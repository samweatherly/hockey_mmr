class CreateFutures < ActiveRecord::Migration
  def change
    create_table :futures do |t|
      t.references :home_team
      t.references :away_team
      t.float :home_mmr
      t.float :away_mmr
      t.date :date
      t.float :expected_result

      t.timestamps null: false
    end
  end
end
