class RemoveHomeNameFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :home_name, :string
  end
end
