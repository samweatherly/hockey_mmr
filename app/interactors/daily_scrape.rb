require 'capybara'
require 'capybara/poltergeist' #gem 'poltergeist'
require 'capybara/dsl'

class DailyScrape
  include Delayed::RecurringJob
  include Capybara::DSL
  Capybara.default_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: false)
  end
  run_every 1.day
  run_at '11:55pm'
  timezone 'US/Pacific'
  queue 'slow-jobs'

  def create_game( playoff, i, extra_time, home_team, away_team, home_goals,
                    away_goals, date)
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
                "Mighty Ducks of Anaheim"=>1, "Phoenix Coyotes"=>2, "Atlanta Thrashers"=>30,
                "Montréal Canadiens"=>16}

    query_home = Team.find(teamHash[home_team])
    query_away = Team.find(teamHash[away_team])

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
    elsif home_goals > away_goals # if extra time wonky (scraper sometimes pulls text from other column)
      result = 1
    elsif away_goals > home_goals # if extra time wonky
      result = 0
    end
    puts 'result'
    expected_home = 1 / (1 + 10**((away_mmr - home_mmr)/400.0))
    expected_away = 1 - expected_home

    # adjust ratings
    new_home_mmr = home_mmr + query_home.k_value * (result - expected_home)
    new_away_mmr = away_mmr + query_away.k_value * ((1 - result) - expected_away)

    home_change = (new_home_mmr - home_mmr)
    away_change = (new_away_mmr - away_mmr)

    g = Game.create home_goals: home_goals, home_mmr: home_mmr, home_team_id: query_home.id,
                    away_goals: away_goals, away_mmr: away_mmr, away_team_id: query_away.id,
                    date: date, extra_time: extra_time, home_rating_change: home_change,
                    away_rating_change: away_change, playoff: playoff,
                    season: season, result: result, expected: expected_home
    g.update_game_count
    g.update_mmr(home_change, away_change)
  end



  def perform
    # today = (Time.new - 1.day).to_s.split(' ')[0]
    today = Time.new.to_s.split(' ')[0]

    visit "https://www.nhl.com/scores"
    puts "Today: #{today}"
    all("ul.nhl-scores__list.nhl-scores__list--games li").each do |row|
      puts row.text
        if row.text.split(",")[0].strip[-3..-1] == 'day'
          @date = Date.parse row.text
          puts "date: #{@date}"
        end
      if @date.to_s == today && row.text.match("FINAL")
        puts "@date == today"
        if row.text.match("@")
          puts "@"
          away_team = row.text.split("@")[0]
          home_team = row.text.split("@")[1].split("Teams")[0]
          puts 'team'
          away_goals = row.text.split("#{home_team}")[1].split(" ")[-1]
          home_goals = row.text.split("Status")[0].split(" ")[-1]

          puts "team & goals"
          if row.text.split("WATCH")[0].split(" ")[-1] != "FINAL"
              extra_time = row.text.split("WATCH")[0].split(" ")[-1][-2..-1]
          else
            extra_time = nil
          end
          puts 'extra_time'


          if Time.new.month <= 6
            season = Time.new.year
          else
            season = Time.new.year + 1
          end

          playoff = Game.where(season: season).count < 1230 ? false : true

          create_game(playoff, season, extra_time, home_team.strip, away_team.strip, home_goals,
                      away_goals, today)
          puts "#{away_team}: #{away_goals} | #{home_team}: #{home_goals} "
          puts extra_time
          puts "--------------------------------------------------------"
        end #if
      end #if
    end #each row
  end #perform
end
