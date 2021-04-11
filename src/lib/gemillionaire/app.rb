# frozen_string_literal: true

require 'json'
require 'tty-prompt'
require 'colorize'

def prompt_instance
  TTY::Prompt.new
end

# Run top level methods and initialize menu
class App
  attr_accessor :questions, :statistics, :prizes, :main_menu

  def initialize
    check_dependencies
    @questions = JSON.parse(File.read('lib/gemillionaire/questions.json'))
    @statistics = JSON.parse(File.read('lib/gemillionaire/hiscores.json'))
    @prizes = ['0', '500', '1,000', '2,000', '3,000', '5,000', '7,500', '10,000', '12,500', '15,000',
               '25,000', '50,000', '100,000', '250,000', '500,000', '1,000,000'].freeze
    @main_menu = [
      { name: 'New Game', value: -> { new_game } },
      { name: 'Instructions', value: -> { run_instructions } },
      { name: 'Hiscores', value: -> { run_hiscores } },
      { name: 'Exit', value: -> { exit } }
    ]
  end

  def new_game
    game = Game.new
    game.start
  end

  def check_dependencies
    missing_file = 'app.rb' unless File.exist?('lib/gemillionaire/app.rb')
    missing_file = 'game.rb' unless File.exist?('lib/gemillionaire/game.rb')
    missing_file = 'hiscores.json' unless File.exist?('lib/gemillionaire/hiscores.json')
    missing_file = 'questions.json' unless File.exist?('lib/gemillionaire/questions.json')
    return unless missing_file

    puts 'Missing File Error'.bold.red
    puts "Oops! You appear to be missing the file #{missing_file.bold}. Please re-install the gem."
    puts "Visit #{'https://www.github.com/mjsterling/T1A3'.underline} for more information."
    any_key
    exit
  end

  def menu
    loop do
      system('clear')
      display_intro
      prompt = prompt_instance
      puts ('─' * 50).yellow
      prompt.select("For best experience, please maximise your terminal.\n".bold, @main_menu)
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

  def run_instructions
    puts "\nHow To Play Gemillionaire:".bold
    puts 'You must answer 15 multiple-choice questions correctly in a row to win 1 million 💎.'
    puts 'You may walk away at any time and keep your earnings.'
    print 'If you answer a question wrong, you fall back to the last guarantee point - '
    puts '5,000 💎 if 5 questions correct, 25,000 💎 if 10 questions correct.'
    puts 'At any point, you may use one of the three lifelines:'
    puts '   - 50/50: Removes two incorrect options from the list'
    puts '   - Ask The Audience: Each audience member answers the question and the results are displayed as a graph.'
    puts '   - Phone-A-Friend: A friend will say what they think the answer is. They are not always correct, beware!'
    puts "Each lifeline may only be used once.\n"
    any_key
  end

  def run_hiscores
    @statistics = JSON.parse(File.read('lib/gemillionaire/hiscores.json'))
    games_played = @statistics['games_played'].to_i
    total_winnings = @statistics['total_winnings'].to_i
    average_earnings = games_played.zero? ? 0 : total_winnings / games_played
    puts "\nTotal games played: #{games_played}"
    puts "Top score: #{@statistics['hiscore']} 💎"
    puts "Total winnings: #{total_winnings} 💎"
    puts "Average earnings per game: #{average_earnings} 💎\n"
    any_key
  end

  def any_key
    print 'Press any key to continue.'.green
    $stdin.getch
  end
end

require 'gemillionaire/game'
