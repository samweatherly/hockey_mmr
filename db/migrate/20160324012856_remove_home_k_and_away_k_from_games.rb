class RemoveHomeKAndAwayKFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :home_k, :integer
    remove_column :games, :away_k, :integer
  end
end
