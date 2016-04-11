require 'open-uri'

class UpcomingGames
  include Delayed::RecurringJob
  run_every 1.day
  run_at '1:03pm'
  timezone 'US/Pacific'
  queue 'slow-jobs'

  def create_future_game(date, home_team, away_team)
    puts 'create future game'
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
        puts 'rescue'
      end
      puts 'query'


      home_team_id = query_home.id
      away_team_id = query_away.id
      home_mmr = query_home.mmr
      away_mmr = query_away.mmr
      expected_result = 1 / (1 + 10**((away_mmr - home_mmr)/400.0))
      puts 'assign variables'

      Future.create(home_team_id: home_team_id, away_team_id: away_team_id,
                    date: date, expected_result: expected_result,
                    home_mmr: home_mmr, away_mmr: away_mmr)
  end

  def perform
    puts 'perform'
    Future.destroy_all
    current_time = Time.new
    today = current_time.to_s.split(' ')[0]

    if current_time.month <= 6
      season = current_time.year
    else
      season = current_time.year + 1
    end
    doc = Nokogiri::HTML(open("http://www.hockey-reference.com/leagues/NHL_#{season}_games.html"))
    puts 'nokogiri'
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
          puts 'if today'
          puts game
          p game
          # create_future_game(valid_date, home_team, away_team)
          create_future_game(game[2], game[1], game[0])
        elsif game[2] >= today # && games_today <= 5 && later_games <= 5
          # later_games += 1
          puts 'if tomorrow+'
          p game
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
          puts 'if today'
          puts game
          p game
          # create_future_game(valid_date, home_team, away_team)
          create_future_game(game[2], game[1], game[0])
        elsif game[2] >= today # && games_today <= 5 && later_games <= 5
          # later_games += 1
          puts 'if tomorrow+'
          p game
          # create_future_game(valid_date, home_team, away_team)
          create_future_game(game[2], game[1], game[0])
        end #if
      end #if
    end #gamesArr.each
  end
end
