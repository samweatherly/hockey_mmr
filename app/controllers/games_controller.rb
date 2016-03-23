class GamesController < ApplicationController


  def new
    @game = Game.new
  end

  def create

  end

  private

  def game_params
    params.require(:game).permit(:)
  end


end
