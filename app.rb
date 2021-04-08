# frozen_string_literal: true

require 'json'
require 'tty-prompt'
require 'colorize'

def prompt_instance
  TTY::Prompt.new
end

# Run top level methods and initialize menu
class App
  def initialize
    @questions = JSON.parse(File.read('./questions.json'))
    @statistics = JSON.parse(File.read('./hiscores.json'))
    @prizes = ['0', '500', '1,000', '2,000', '3,000', '5,000', '7,500', '10,000', '12,500', '15,000',
               '25,000', '50,000', '100,000', '250,000', '500,000', '1,000,000'].freeze
    @menu = [
      { name: 'New Game', value: -> { Game.new } },
      { name: 'Instructions', value: -> { run_instructions } },
      { name: 'Hiscores', value: -> { run_hiscores } },
      { name: 'Exit', value: -> { exit } }
    ]
  end

  def menu
    loop do
      system('clear')
      display_intro
      prompt = prompt_instance
      puts ('─' * 50).yellow
      prompt.select("For best experience, please maximise your terminal.\n".bold, @menu)
      File.write('./hiscores.json', JSON.dump(@statistics))
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
    puts 'Press Enter to continue'.green
    gets
  end

  def run_hiscores
    games_played = @statistics['games_played'].to_i
    total_winnings = @statistics['total_winnings'].to_i
    average_earnings = games_played.zero? ? 0 : total_winnings / games_played
    puts "\nTotal games played: #{games_played}"
    puts "Top score: #{@statistics['hiscore']} 💎"
    puts "Total winnings: #{total_winnings} 💎"
    puts "Average earnings per game: #{average_earnings} 💎\n"
    puts 'Press Enter to continue.'.green
    gets
  end
end

require_relative 'game'
