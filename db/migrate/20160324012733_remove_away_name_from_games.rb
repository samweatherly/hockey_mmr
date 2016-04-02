class RemoveAwayNameFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :away_name, :string
  end
end
