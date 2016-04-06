class FuturesController < ApplicationController
  def create
    future = Future.new future_params
    if future.save
      redirect_to future, success: "Future successfully created."
    else
      render :new, alert: "Future creation failed."
    end
  end

  def index
    @futures = Future.all
    @teams = Team.order("mmr DESC")
  end

  def destroy
    # before_action :find_game
    @game.destroy
    redirect_to games_path
  end

  private

  def future_params
    params.require(:future).permit( :home_team_id, :away_team_id, :date,
                                    :expected_result, :home_mmr, :away_mmr)
  end

  def find_future
    @future = Future.find params[:id]
  end



end
