class AddExpectedToGames < ActiveRecord::Migration
  def change
    add_column :games, :expected, :float
  end
end
