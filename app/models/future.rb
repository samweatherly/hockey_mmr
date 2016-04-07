class Future < ActiveRecord::Base
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'



  def home_team_name
    home_team.name
  end

  def away_team_name
    away_team.name
  end

  def date_timeline
    # DD/MM/YYYY
    holder = self.date
    month = holder.month.to_s
    day = holder.day.to_s
    if month.length == 1
      month = "0" + month
    end
    if day.length == 1
      day = "0" + day
    end
    "#{day}/#{month}/#{holder.year}"
  end

  def away_logo
    away_team.logo.url(:thumb)
  end
  def home_logo
    home_team.logo.url(:thumb)
  end

  # def date_display
  # holder = self.date
  # "#{holder.month} #{holder.day}"
  # end

end
