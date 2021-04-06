require 'json'
require 'tty-prompt'
require 'tty-table'
require 'colorize'

PRIZES = ['0', '500', '1,000', '2,000', '3,000', '5,000', '7,500', '10,000', '12,500', '15,000',
          '25,000', '50,000', '100,000', '250,000', '500,000', '1,000,000'].freeze

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
  attr_accessor :q_sample, :prizes, :score, :lifelines, :fifty_fifty_avail, :fifty_fifty_active,
                :ask_the_audience_avail, :ask_the_audience_active, :phone_a_friend_avail, :phone_a_friend_active, :win,
                :lose, :fifty_fifty_options

  def initialize
    super

    @score = 0
    @fifty_fifty_avail = true
    @ask_the_audience_avail = true
    @phone_a_friend_avail = true
    @fifty_fifty_active = false
    @ask_the_audience_active = false
    @phone_a_friend_active = false
    @win = false
    @lose = false
    @q_sample = @@questions.sample(15)
    @fifty_fifty_options = [0, 1, 2, 3]

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
    if ask_the_audience_active

    end
    puts
    choices = [
      { name: "A - #{current_q['A']}", value: -> { check_answer('A') } },
      { name: "B - #{current_q['B']}", value: -> { check_answer('B') } },
      { name: "C - #{current_q['C']}", value: -> { check_answer('C') } },
      { name: "D - #{current_q['D']}", value: -> { check_answer('D') } },
      { name: "Walk away with #{PRIZES[@score]} \u{1F48E}", value: -> { confirm_walk_away } },
      { name: 'Lifeline - 50/50', value: -> { fifty_fifty } },
      { name: 'Lifeline - Ask The Audience', value: -> { ask_the_audience } },
      { name: 'Lifeline - Phone A Friend', value: -> { phone_a_friend } }
    ]
    unless fifty_fifty_avail
        choices[5][:disabled] = ''
        choices[5][:name] = 'Lifeline - 50/50'.red
    end
    unless ask_the_audience_avail
        choices[6][:disabled] = '' 
        choices[6][:name] = choices[6][:name].red
    end
    unless phone_a_friend_avail
        choices[7][:disabled] = '' 
    if fifty_fifty_active
      # check right answer
      choices[@fifty_fifty_options[0]][:name] = choices[@fifty_fifty_options[0]][:name].red
      choices[@fifty_fifty_options[0]][:disabled] = ''
      choices[@fifty_fifty_options[1]][:name] = choices[@fifty_fifty_options[1]][:name].red
      choices[@fifty_fifty_options[1]][:disabled] = ''
    end
    q_prompt = prompt_instance
    q_prompt.select('Select an option:', choices, per_page: 8)
  end

  def check_answer(answer)
    current_q = @q_sample[@score]
    if answer == current_q['answer']
      @score += 1
      @fifty_fifty_active = false
      @ask_the_audience_active = false
      @phone_a_friend_active = false
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
      elsif [6, 11].include?(i)
        print "| #{PRIZES[i]} \u{1F48E} ".underline
      else
        print "| #{PRIZES[i]} \u{1F48E} "
      end
      i += 1
    end
    puts '|'
  end

  def fifty_fifty
    @fifty_fifty_avail = false
    @fifty_fifty_active = true
    answer = @questions[@score]['answer']
    case answer
    when 'A'
      @fifty_fifty_options.slice!(0)
    when 'B'
      @fifty_fifty_options.slice!(1)
    when 'C'
      @fifty_fifty_options.slice!(2)
    when 'D'
      @fifty_fifty_options.pop
    end
    @fifty_fifty_options.slice!(rand(2))
  end

  def ask_the_audience
    @ask_the_audience_active = true
    @ask_the_audience_avail = false
  end

  def phone_a_friend
    @phone_a_friend_active = true
    @phone_a_friend_avail = false
  end
end

app = App.new
app.run_app
