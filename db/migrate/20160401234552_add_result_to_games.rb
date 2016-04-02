class AddResultToGames < ActiveRecord::Migration
  def change
    add_column :games, :result, :float
  end
end
