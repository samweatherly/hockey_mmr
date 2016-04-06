class Team < ActiveRecord::Base
  #game
  has_many :home_games, :class_name => 'Game', foreign_key: 'home_team_id'
  has_many :away_games, :class_name => 'Game', foreign_key: 'away_team_id'

  #future
  has_many :home_futures, :class_name => 'Future', foreign_key: 'home_team_id'
  has_many :away_futures, :class_name => 'Future', foreign_key: 'away_team_id'
  
  validates :name, presence: true

  after_initialize :set_defaults

  # def update_games_played
  #   self.total_games += 1
  #   self.save
  # end



  private
# new teams have an initial MMR of 1500. Additionally they have a K of 40 for their
# first 30 games. This will adjust to 20 after 30 games have been played.
  def set_defaults
    self.mmr ||= 1500
    self.k_value ||= 40
    self.home_mmr ||= self.mmr
    self.away_mmr ||= self.mmr
    self.active ||= true
    self.total_games ||= 0
  end

end
