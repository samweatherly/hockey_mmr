class RemoveColumnFromTeams < ActiveRecord::Migration
  def change
    remove_column :teams, :division, :string
  end
end
