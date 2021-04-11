# frozen_string_literal: true

# Initialize a new game instance
class Game < App
  attr_accessor :q_sample, :score, :lifelines, :game_over, :keys

  def initialize
    super
    @q_sample = @questions.sample(15)
    @score = 0
    @lifelines = { fifty: { status: 'avail', value: [0, 1, 2, 3] },
                   ask: { status: 'avail', value: rng_graph },
                   phone: { status: 'avail', value: [] } }
    @game_over = false
    @keys = { 'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3 }
  end

  def start
    display_question until @game_over
  end

  def display_question
    system('clear')
    current_q = @q_sample[@score]
    score_table
    puts "\nQuestion #{@score + 1}: #{current_q['question']}\n".bold
    display_lifelines
    prompt = prompt_instance
    prompt.select('Select an option:'.bold, gen_menu(current_q), per_page: 8)
  end

  def display_lifelines
    display_ask_the_audience if @lifelines[:ask][:status] == 'active'
    display_phone_a_friend if @lifelines[:phone][:status] == 'active'
  end

  def display_ask_the_audience
    puts 'Ask The Audience'.center(40, ' ')
    @keys.each do |k, v|
      print "#{k} - #{@lifelines[:ask][:value][v]}%".center(10, ' ')
    end
    puts "\n\n"
  end

  def display_phone_a_friend
    puts 'Phone A Friend'.center(40, ' ')
    puts "\'I think it's #{@lifelines[:phone][:value]}.\'".center(40, ' ')
    puts
  end

  def gen_menu(current_q)
    answer_key = current_q['answer']
    answer_value = current_q[answer_key]
    choices = %w[A B C D].map do |k|
      { name: "#{k} - #{current_q[k]}", value: -> { check_answer(answer_key, answer_value, k) } }
    end
    disable_answers(choices) if @lifelines[:fifty][:status] == 'active'
    add_lifelines(choices, answer_key)
  end

  def disable_answers(choices)
    @keys.each_value do |v|
      if @lifelines[:fifty][:value].include?(v)
        choices[v][:name] = choices[v][:name].red
        choices[v][:disabled] = '- (50/50)'.red
      end
    end
    choices
  end

  def add_lifelines(choices, answer_key)
    choices << { name: "Walk away with #{@prizes[@score].yellow.bold} 💎", value: -> { confirm_walk_away } }
    choices << { name: ' ½ - 50/50', value: -> { fifty_fifty(answer_key) } }
    choices << { name: '🗨  - Ask The Audience', value: -> { ask_the_audience(answer_key) } }
    choices << { name: '📱 - Phone A Friend', value: -> { phone_a_friend(answer_key) } }
    disable_lifelines(choices)
  end

  def lifeline_statuses
    [@lifelines[:fifty][:status], @lifelines[:ask][:status], @lifelines[:phone][:status]]
  end

  def disable_lifelines(choices)
    lifeline_statuses.each_with_index do |lifeline, index|
      unless lifeline == 'avail'
        choices[index + 5][:name] = choices[index + 5][:name].red
        choices[index + 5][:disabled] = '- used'.red
      end
    end
    choices
  end

  def check_answer(answer_key, answer_value, input)
    return you_lose(answer_key, answer_value) unless input == answer_key

    @score += 1
    reset_lifelines
    you_win if @score == 15
  end

  def reset_lifelines
    @lifelines[:fifty][:status]  = 'used' if @lifelines[:fifty][:status]  == 'active'
    @lifelines[:ask][:status] = 'used' if @lifelines[:ask][:status] == 'active'
    @lifelines[:phone][:status] = 'used' if @lifelines[:phone][:status] == 'active'
  end

  def you_win
    system('clear')
    @game_over = true
    score_table
    puts 'CONGRATULATIONS! You won 1 million gems!!!!'.bold
    update_stats(1_000_000)
  end

  def you_lose(answer_key, answer_value)
    puts "Incorrect! The correct answer was #{answer_key} - #{answer_value}."
    @game_over = true
    prize = @prizes[@score / 5 * 5] # removes remainder and returns nearest safe point at 0, 5 or 10
    puts "You won #{prize} 💎. Better luck next time!"
    update_stats(prize.gsub(',', '').to_i)
  end

  def update_stats(prize)
    @statistics['games_played'] = @statistics['games_played'].to_i + 1
    @statistics['total_winnings'] = @statistics['total_winnings'].to_i + prize
    @statistics['hiscore'] = prize if prize > @statistics['hiscore'].to_i
    File.write("#{__dir__}/hiscores.json", JSON.dump(@statistics))
    any_key
  end

  def confirm_walk_away
    prompt = prompt_instance
    prompt.select('Are you sure?') do |menu|
      menu.choice 'Yes', -> { walk_away }
      menu.choice 'No', -> {}
    end
  end

  def walk_away
    @game_over = true
    prize = @prizes[@score]
    puts "You won #{prize} 💎. Better luck next time!"
    update_stats(prize.gsub(',', '').to_i)
  end

  def score_table
    16.times do |i|
      puts '|' if [5, 10, 15].include?(i)
      print '|'
      print i == @score ? "#{@prizes[i]} 💎".center(13).bold.yellow : "#{@prizes[i]} 💎".center(13)
    end
    puts '|'
  end

  def fifty_fifty(answer)
    @lifelines[:fifty][:status] = 'active'
    @lifelines[:fifty][:value].slice!(@keys[answer])
    @lifelines[:fifty][:value].slice!(rand(2))
  end

  def rng_graph
    total = 60
    graph = []
    3.times do
      percent = rand(total)
      graph << percent + 10
      total -= percent
    end
    graph << total + 10
    graph.shuffle!
  end

  def ask_the_audience(answer)
    @lifelines[:ask][:status] = 'active'
    return if rand(2).zero?

    # increase correct answer percentage by 30% and reduce others by 10%
    @lifelines[:ask][:value].map!.with_index { |n, index| n + (index == @keys[answer] ? 30 : -10) }
  end

  def phone_a_friend(answer)
    @lifelines[:phone][:status] = 'active'
    @lifelines[:phone][:value] = rand(2).zero? ? %w[A B C D].sample : answer
  end
end
