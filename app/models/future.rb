class Future < ActiveRecord::Base
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'



  def home_team_name
    home_team.name
  end

  def away_team_name
    away_team.name
  end

end
