class GamesController < ApplicationController

  before_action :find_game, only: [:show, :edit, :update, :destroy]

  def new
    @game = Game.new
  end

  def create
    game = Game.new game_params
    if game.save
      game.update_game_count
      redirect_to game, success: "Game successfully created."
    else
      render :new, alert: "Game creation failed."
    end
  end

  def show
    # before_action :find_game
  end

  def index
    @games = Game.all.limit(82)
  end

  def edit
    # before_action :find_game
  end

  def update
    # before_action :find_game
    @game.update game_params
    redirect_to @game, success: "Game successfully updated"
  end

  def destroy
    # before_action :find_game
    @game.destroy
    redirect_to games_path
  end

  private

  def game_params
    params.require(:game).permit( :home_team_id, :away_team_id, :home_goals,
                                  :away_goals, :date, :extra_time, :playoff,
                                  :season, :result, :home_rating_change,
                                  :away_rating_change, :expected)
  end

  def find_game
    @game = Game.find params[:id]
  end

end
