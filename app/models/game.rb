class Game < ActiveRecord::Base
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'

  def home_team_name
    home_team.name if home_team
  end

  def away_team_name
    away_team.name if away_team
  end

  def update_game_count
    t = home_team
    t.total_games += 1
    if t.total_games > 30 && t.k_value == 40
      t.k_value = 20
    end
    t.save
    t2 = away_team
    t2.total_games += 1
    if t2.total_games > 30 && t2.k_value == 20
      t2.k_value = 20
    end
    t2.save
  end

  def update_mmr(home_change, away_change)
    t = home_team
    t2 = away_team

    t.mmr += home_change
    t.home_mmr += home_change
    t.save

    t2.mmr += away_change
    t2.away_mmr += away_change
    t2.save
  end



end
