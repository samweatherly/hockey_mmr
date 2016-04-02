class AddColumnToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :total_games, :integer
  end
end
