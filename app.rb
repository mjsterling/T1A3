require 'json'
require 'tty-prompt'
require 'tty-table'
require 'colorize'

PRIZES = ['0', '500', '1,000', '2,000', '3,000', '5,000', '7,500', '10,000', '12,500', '15,000', '25,000',
          '50,000', '100K', '250K', '500K', '1 MILLION']

def prompt_instance
  TTY::Prompt.new
end

# Run top level methods and initialize menu
class App
  def initialize
    @@questions = JSON.parse(File.read('./questions.json'))
    @@statistics = JSON.parse(File.read('./hiscores.json'))
  end

  def run_app
    menu
  end

  def menu
    # TODO: - WWTBAM LOGO
    loop do
      prompt = prompt_instance
      prompt.select('Select an option:') do |menu|
        menu.choice 'New Game', -> { Game.new }
        menu.choice 'Instructions', -> { run_instructions }
        menu.choice 'Hiscores', -> { run_hiscores }
        menu.choice 'Exit', -> { exit }
      end
      File.write('./hiscores.json', JSON.dump(@@statistics))
    end
  end

  def run_hiscores
    games_played = @@statistics['games_played'].to_i
    hiscore = @@statistics['hiscore'].to_i
    total_winnings = @@statistics['total_winnings'].to_i
    average_earnings = games_played.zero? ? 0 : total_winnings / games_played
    puts
    puts "Total games played: #{games_played}"
    puts "Top score: #{hiscore} \u{1F48E}"
    puts "Total winnings: #{total_winnings} \u{1F48E}"
    puts "Average earnings per game: #{average_earnings} \u{1F48E}"
    puts
  end
end

# Initialize a new game instance
class Game < App
  attr_accessor :q_sample, :prizes, :score, :lifelines, :fifty_fifty, :ask_the_audience, :phone_a_friend, :win, :lose

  def initialize
    super

    @score = 0
    @fifty_fifty = true
    @ask_the_audience = true
    @phone_a_friend = true
    @win = false
    @lose = false
    @q_sample = @@questions.sample(15)

    run_game
  end

  def run_game
    display_question until @win || @lose
  end

  def display_question
    system('clear')
    current_q = @q_sample[@score]
    puts
    score_table
    puts
    puts "Question #{@score + 1}: #{current_q['question']}".bold
    puts
    q_prompt = prompt_instance
    q_prompt.select('Select an option:') do |menu|
      menu.choice "A - #{current_q['A']}", -> { check_answer('A') }
      menu.choice "B - #{current_q['B']}", -> { check_answer('B') }
      menu.choice "C - #{current_q['C']}", -> { check_answer('C') }
      menu.choice "D - #{current_q['D']}", -> { check_answer('D') }
      menu.choice 'Walk Away', -> { confirm_walk_away }
      menu.choice '50/50', -> { fifty_fifty }
      menu.choice 'Ask the Audience', -> { ask_the_audience }
      menu.choice 'Phone a friend', -> { phone_a_friend }
    end
  end

  def check_answer(answer)
    current_q = @q_sample[@score]
    if answer == current_q['answer']
      @score += 1
      @win = true if @score == 15
    else
      @lose = true
      correct_answer = current_q['answer']
      puts "Incorrect! The correct answer was #{correct_answer} - #{current_q[correct_answer]}."
      you_lose
    end
  end

  def you_lose
    prize = 0
    case @score
    when 10..14
      prize = PRIZES[10].to_i
    when 5..9
      prize = PRIZES[5].to_i
    end
    puts "You won #{prize} \u{1F48E}. Better luck next time!"
    @@statistics['games_played'] = (@@statistics['games_played'].to_i + 1).to_s
    @@statistics['total_winnings'] = (@@statistics['total_winnings'].to_i + prize).to_s
  end

  def confirm_walk_away
    prompt = prompt_instance
    prompt.select('Are you sure?') do |menu|
      menu.choice 'Yes', -> { walk_away }
      menu.choice 'No', -> {}
    end
  end

  def walk_away
    @lose = true
    prize = PRIZES[@score].gsub(',', '').to_i
    puts "You won #{PRIZES[@score]} \u{1F48E}. Better luck next time!"
    @@statistics['games_played'] = (@@statistics['games_played'].to_i + 1).to_s
    @@statistics['total_winnings'] = (@@statistics['total_winnings'].to_i + prize).to_s
  end

  def score_table
    i = 0
    while i < 16
      if i == @score
        print "| #{PRIZES[i].yellow.bold} \u{1F48E} "
      else
        print "| #{PRIZES[i]} \u{1F48E} "
      end
      i += 1
    end
    puts '|'
  end

  def 
end

app = App.new
app.run_app
