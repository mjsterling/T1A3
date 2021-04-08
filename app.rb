require 'json'
require 'tty-prompt'
require 'colorize'

def prompt_instance
  TTY::Prompt.new
end

# Run top level methods and initialize menu
class App
  def initialize
    @@questions = JSON.parse(File.read('./questions.json'))
    @@statistics = JSON.parse(File.read('./hiscores.json'))
    @@PRIZES = ['0', '500', '1,000', '2,000', '3,000', '5,000', '7,500', '10,000', '12,500', '15,000',
                '25,000', '50,000', '100,000', '250,000', '500,000', '1,000,000'].freeze
  end

  def menu
    loop do
      system('clear')
      display_intro
      prompt = prompt_instance
      puts ('─' * 50).yellow
      prompt.select("For best experience, please maximise your terminal.\n".bold) do |menu|
        menu.choice 'New Game', -> { Game.new }
        menu.choice 'Instructions', -> { run_instructions } # TODO
        menu.choice 'Hiscores', -> { run_hiscores }
        menu.choice 'Exit', -> { exit }
      end
      File.write('./hiscores.json', JSON.dump(@@statistics))
    end
  end

  def display_intro
    puts ('─' * 50).yellow
    puts "#{' ' * 12}🇬 ​​​​​🇪​​​​​ 🇲​​​​​ 🇮 ​​🇱​​​​​ 🇱​​​​​ 🇮​​​​​ 💎🇳​​​​​ 🇦​​​​​ 🇮​​​​​ 🇷​​​​​ 🇪#{' ' * 12}​​​​​"
    puts "#{('─' * 50).yellow}\n"
    puts "Who Wants To Be A Terminal-Based Millionaire?\n".yellow.bold
    puts 'Created by Matthew Sterling, 2021.'
    puts "Source code: https://github.com/mjsterling/T1A3 \n"
  end

  def run_hiscores
    games_played = @@statistics['games_played'].to_i
    total_winnings = @@statistics['total_winnings'].to_i
    average_earnings = games_played.zero? ? 0 : total_winnings / games_played
    puts "\nTotal games played: #{games_played}"
    puts "Top score: #{@@statistics['hiscore']} 💎"
    puts "Total winnings: #{total_winnings} 💎"
    puts "Average earnings per game: #{average_earnings} 💎\n"
    puts 'Press Enter to continue.'.green
    gets
  end
end

require_relative 'game'
