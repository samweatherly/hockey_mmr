class TeamsController < ApplicationController

  def new
    @team = Team.new
  end

  def create
    team = Team.new team_params
    if team.save
      redirect_to team, success: "Team created successfully."
    else
      render :new, alert: "Team creation failed."
    end
  end


  private

  def team_params
    params.require(:team).permit( :name, :mmr, :k_value, :home_mmr, :away_mmr,
                                  :logo, :active)
  end

end
