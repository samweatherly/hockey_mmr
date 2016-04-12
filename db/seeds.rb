require 'open-uri'

#TEAMS
teamsArr = ["Anaheim Ducks", "Arizona Coyotes", "Boston Bruins", "Buffalo Sabres",
            "Calgary Flames", "Carolina Hurricanes", "Chicago Blackhawks",
            "Colorado Avalanche", "Columbus Blue Jackets", "Dallas Stars",
            "Detroit Red Wings", "Edmonton Oilers", "Florida Panthers",
            "Los Angeles Kings", "Minnesota Wild", "Montreal Canadiens",
            "Nashville Predators", "New Jersey Devils", "New York Islanders",
            "New York Rangers", "Ottawa Senators", "Philadelphia Flyers",
            "Pittsburgh Penguins", "San Jose Sharks", "St. Louis Blues",
            "Tampa Bay Lightning", "Toronto Maple Leafs", "Vancouver Canucks",
            "Washington Capitals", "Winnipeg Jets"]
conferences = {"Anaheim Ducks"=>"Western", "Arizona Coyotes"=>"Western", "Boston Bruins"=>"Eastern",
            "Buffalo Sabres"=>"Eastern", "Calgary Flames"=>"Western", "Carolina Hurricanes"=>"Eastern",
            "Chicago Blackhawks"=>"Western", "Colorado Avalanche"=>"Western",
            "Columbus Blue Jackets"=>"Eastern", "Dallas Stars"=>"Western", "Detroit Red Wings"=>"Eastern",
            "Edmonton Oilers"=>"Western", "Florida Panthers"=>"Eastern", "Los Angeles Kings"=>"Western",
            "Minnesota Wild"=>"Western", "Montreal Canadiens"=>"Eastern", "Nashville Predators"=>"Western",
            "New Jersey Devils"=>"Eastern", "New York Islanders"=>"Eastern", "New York Rangers"=>"Eastern",
            "Ottawa Senators"=>"Eastern", "Philadelphia Flyers"=>"Eastern", "Pittsburgh Penguins"=>"Eastern",
            "San Jose Sharks"=>"Western", "St. Louis Blues"=>"Western", "Tampa Bay Lightning"=>"Eastern",
            "Toronto Maple Leafs"=>"Eastern", "Vancouver Canucks"=>"Western", "Washington Capitals"=>"Eastern",
            "Winnipeg Jets"=>"Western"}
teamsArr.each do |team|
  t = Team.create(name: team)
  t.logo = Rails.root.join("app/assets/images/nhl_logos/#{team.downcase.gsub(".", "").split(" ").join("-")}.png").open
  t.conference = conferences[team]
  t.save
end

@teamHash = {"Anaheim Ducks"=>1, "Arizona Coyotes"=>2, "Boston Bruins"=>3,
            "Buffalo Sabres"=>4, "Calgary Flames"=>5, "Carolina Hurricanes"=>6,
            "Chicago Blackhawks"=>7, "Colorado Avalanche"=>8,
            "Columbus Blue Jackets"=>9, "Dallas Stars"=>10, "Detroit Red Wings"=>11,
            "Edmonton Oilers"=>12, "Florida Panthers"=>13, "Los Angeles Kings"=>14,
            "Minnesota Wild"=>15, "Montreal Canadiens"=>16, "Nashville Predators"=>17,
            "New Jersey Devils"=>18, "New York Islanders"=>19, "New York Rangers"=>20,
            "Ottawa Senators"=>21, "Philadelphia Flyers"=>22, "Pittsburgh Penguins"=>23,
            "San Jose Sharks"=>24, "St. Louis Blues"=>25, "Tampa Bay Lightning"=>26,
            "Toronto Maple Leafs"=>27, "Vancouver Canucks"=>28, "Washington Capitals"=>29,
            "Winnipeg Jets"=>30,
            "Mighty Ducks of Anaheim"=>1, "Phoenix Coyotes"=>2, "Atlanta Thrashers"=>30}

#GAMES
# current date so we don't gather data for games that have not been played yet
today = Time.new.to_s.split(' ')[0]

def create_games(game, playoff, i)
  # QUERY once, take into account team names change
  query_home = Team.find(@teamHash[game[2]])
  query_away = Team.find(@teamHash[game[1]])
  # home_search_word = game[1].split(" ").last # takes last word of string to account for name changes
  # away_search_word = game[2].split(" ").last # takes last word of string to account for name changes
  # query_home = Team.where("name ILIKE ?", "%#{home_search_word}%")[0]
  # query_away = Team.where("name ILIKE ?", "%#{away_search_word}%")[0]

  #ORGANIZE & assign data
  date = game[0]
  home_team_id = query_home.id
  away_team_id = query_away.id
  home_goals = game[4].to_i
  away_goals = game[3].to_i
  # playoff = false
  extra_time = nil
  extra_time = game[5] if game[5]
  home_mmr = query_home.mmr
  away_mmr = query_away.mmr
  season = i # seasons.each do
  if home_goals == away_goals
    result = 0.5
  elsif home_goals > away_goals && extra_time == nil
    result = 1
  elsif away_goals > home_goals && extra_time == nil
    result = 0
  elsif home_goals > away_goals && extra_time[-2..-1] == "OT"
    result = 0.75
  elsif away_goals > home_goals && extra_time[-2..-1] == "OT"
    result = 0.25
  elsif home_goals > away_goals && extra_time == "SO"
    result = 0.6
  elsif away_goals > home_goals && extra_time == "SO"
    result = 0.4
  elsif home_goals > away_goals # if extra time wonky
    result = 1
  elsif away_goals > home_goals # if extra time wonky
    result = 0
  end
  # calc probabililty, E(a) =  1 / ( 1 + 10^((R(b) - R(a))/400))
  expected_home = 1 / (1 + 10**((away_mmr - home_mmr)/400.0))
  expected_away = 1 - expected_home

  # adjust ratings
  new_home_mmr = home_mmr + query_home.k_value * (result - expected_home)
  new_away_mmr = away_mmr + query_away.k_value * ((1 - result) - expected_away)

  home_change = (new_home_mmr - home_mmr)
  away_change = (new_away_mmr - away_mmr)

  g = Game.create home_goals: home_goals, home_mmr: home_mmr, home_team_id: home_team_id,
                  away_goals: away_goals, away_mmr: away_mmr, away_team_id: away_team_id,
                  date: date, extra_time: extra_time, home_rating_change: home_change,
                  away_rating_change: away_change, playoff: playoff,
                  season: season, result: result, expected: expected_home
  g.update_game_count
  g.update_mmr(home_change, away_change)
end


# Fetch and parse HTML document
# no 2005 due to lockout
seasons = %w(2001 2002 2003 2004 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016)
# seasons = [2016]
seasons.each do |i|
  doc = Nokogiri::HTML(open("http://www.hockey-reference.com/leagues/NHL_#{i}_games.html"))

  # REGULAR SEASON, 1230 games present era, non-lockout
  gamesXML = []
  doc.css('#div_games tbody tr').each do |row|
    gamesXML.push(row.search('a').xpath('text()') + row.search('td').xpath('text()'))
  end
  # puts each game into a nested array inside gamesArr - data as string
  gamesArr = []
  gamesArr = gamesXML.map do |game|
    game.map do |x|
      x.to_s
    end
  end
  # assign data to variables and create game row in table
  gamesArr.each do |game|
    # break loop if nokgiri starts pulling current/future game data
    if game[0] >= today
      break
    end
    playoff = false
    create_games(game, playoff, i)
  end



# PLAYOFFS
  gamesXML = []
  doc.css('#div_games_playoffs tbody tr').each do |row|
    gamesXML.push(row.search('a').xpath('text()') + row.search('td').xpath('text()'))
  end

  # puts each game into a nested array inside gamesArr - data as string
  gamesArr = []
  gamesArr = gamesXML.map do |game|
    game.map do |x|
      x.to_s
    end
  end
  # assign data to variables and create game row in table
  gamesArr.each do |game|
    # break loop if nokgiri starts pulling current/future game data
    if game[0] >= today
      break
    end
    playoff = true
    create_games(game, playoff, i)
  end

end #seasons each









def create_future_game(date, home_team, away_team)
  # puts 'create future game'
  teamHash = {"Anaheim Ducks"=>1, "Arizona Coyotes"=>2, "Boston Bruins"=>3,
              "Buffalo Sabres"=>4, "Calgary Flames"=>5, "Carolina Hurricanes"=>6,
              "Chicago Blackhawks"=>7, "Colorado Avalanche"=>8,
              "Columbus Blue Jackets"=>9, "Dallas Stars"=>10, "Detroit Red Wings"=>11,
              "Edmonton Oilers"=>12, "Florida Panthers"=>13, "Los Angeles Kings"=>14,
              "Minnesota Wild"=>15, "Montreal Canadiens"=>16, "Nashville Predators"=>17,
              "New Jersey Devils"=>18, "New York Islanders"=>19, "New York Rangers"=>20,
              "Ottawa Senators"=>21, "Philadelphia Flyers"=>22, "Pittsburgh Penguins"=>23,
              "San Jose Sharks"=>24, "St. Louis Blues"=>25, "Tampa Bay Lightning"=>26,
              "Toronto Maple Leafs"=>27, "Vancouver Canucks"=>28, "Washington Capitals"=>29,
              "Winnipeg Jets"=>30,
              "Mighty Ducks of Anaheim"=>1, "Phoenix Coyotes"=>2, "Atlanta Thrashers"=>30}

    begin
      query_home = Team.find(teamHash[home_team])
      query_away = Team.find(teamHash[away_team])
    rescue
      # puts 'rescue'
    end
    # puts 'query'


    home_team_id = query_home.id
    away_team_id = query_away.id
    home_mmr = query_home.mmr
    away_mmr = query_away.mmr
    expected_result = 1 / (1 + 10**((away_mmr - home_mmr)/400.0))
    # puts 'assign variables'

    Future.create(home_team_id: home_team_id, away_team_id: away_team_id,
                  date: date, expected_result: expected_result,
                  home_mmr: home_mmr, away_mmr: away_mmr)
end

def upcoming_games_seed
  # puts 'perform'
  Future.destroy_all
  current_time = Time.new
  today = current_time.to_s.split(' ')[0]

  if current_time.month <= 6
    season = current_time.year
  else
    season = current_time.year + 1
  end
  doc = Nokogiri::HTML(open("http://www.hockey-reference.com/leagues/NHL_#{season}_games.html"))
  # puts 'nokogiri'
  gamesXML = []
  doc.css('#div_games tbody tr').each do |row|
    gamesXML.push(row.search('a').xpath('text()') + row.search('td').xpath('text()'))
  end
  # puts each game into a nested array inside gamesArr - data as string
  gamesArr = []
  gamesArr = gamesXML.map do |game|
    game.map do |x|
      x.to_s
    end
  end

  # assign data to variables and create game row in table
  # games_today = 0
  # later_games = 0
  gamesArr.each do |game|
    if (game[2][0..3] == current_time.year.to_s || game[2][0..3] == (current_time.year + 1).to_s)
      if game[2] == today #&& games_today <= 15
        # games_today += 1

        # puts 'if today'
        # puts game
        # p game

        # create_future_game(valid_date, home_team, away_team)
        create_future_game(game[2], game[1], game[0])
      elsif game[2] >= today # && games_today <= 5 && later_games <= 5
        # later_games += 1

        # puts 'if tomorrow+'
        # p game

        # create_future_game(valid_date, home_team, away_team)
        create_future_game(game[2], game[1], game[0])
      end #if
    end #if
  end #gamesArr.each

  #PLAYOFFS
  gamesXML = []
  doc.css('#div_games_playoffs tbody tr').each do |row|
    gamesXML.push(row.search('a').xpath('text()') + row.search('td').xpath('text()'))
  end
  # puts each game into a nested array inside gamesArr - data as string
  gamesArr = []
  gamesArr = gamesXML.map do |game|
    game.map do |x|
      x.to_s
    end
  end

  # assign data to variables and create game row in table
  # games_today = 0
  # later_games = 0
  gamesArr.each do |game|
    if (game[2][0..3] == current_time.year.to_s || game[2][0..3] == (current_time.year + 1).to_s)
      if game[2] == today #&& games_today <= 15
        # games_today += 1

        # puts 'if today'
        # puts game
        # p game

        # create_future_game(valid_date, home_team, away_team)
        create_future_game(game[2], game[1], game[0])
      elsif game[2] >= today # && games_today <= 5 && later_games <= 5
        # later_games += 1

        # puts 'if tomorrow+'
        # p game

        # create_future_game(valid_date, home_team, away_team)
        create_future_game(game[2], game[1], game[0])
      end #if
    end #if
  end #gamesArr.each
end


upcoming_games_seed
