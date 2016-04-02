class TeamsController < ApplicationController
before_action :find_team, only: [:show, :edit, :update, :destroy]

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

  def show
    # before_action :find_team
  end

  def index
    @teams = Team.all
  end

  def edit
    # before_action :find_team
  end

  def update
    # before_action :find_team
    @team.update team_params
    redirect_to @team, success: "Team successfully updated"
  end

  def destroy
    # before_action :find_team
    @team.destroy
    redirect_to teams_path
  end

  private

  def team_params
    params.require(:team).permit( :name, :mmr, :k_value, :home_mmr, :away_mmr,
                                  :logo, :active, :total_games)
  end

  def find_team
    @team = Team.find params[:id]
  end

end
