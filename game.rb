# Initialize a new game instance
class Game < App
  attr_accessor :q_sample, :score, :lifelines, :game_over, :keys

  def initialize
    super

    @q_sample = @@questions.sample(15)
    @score = 0
    @lifelines = { ff: 'avail', ff_options: [0, 1, 2, 3], ata: 'avail', ata_graph: [], paf: 'avail', paf_answer: [] }
    @game_over = false
    @keys = { 'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3 }

    display_question until @game_over
  end

  def display_question
    system('clear')
    current_q = @q_sample[@score]
    score_table
    puts "\nQuestion #{@score + 1}: #{current_q['question']}\n".bold
    display_ata if @lifelines[:ata] == 'active'
    display_paf if @lifelines[:paf] == 'active'
    prompt = prompt_instance
    prompt.select('Select an option:'.bold, generate_choices(current_q), per_page: 8)
  end

  def generate_choices(current_q)
    answer_k = current_q['answer']
    answer_v = current_q[answer_k]
    choices = []
    @keys.each do |k, v|
      choices << { name: "#{k} - #{current_q[k]}", value: -> { check_answer(answer_k, answer_v, k) } }
      if @lifelines[:ff] == 'active' && @lifelines[:ff_options].include?(v)
        choices.last[:name] = choices.last[:name].red
        choices.last[:disabled] = ''
      end
    end
    choices << { name: "Walk away with #{@@PRIZES[@score]} 💎", value: -> { confirm_walk_away } }
    choices << { name: ' ½ - 50/50', value: -> { fifty_fifty(answer_k) } }
    choices << { name: '🗨  - Ask The Audience', value: -> { ask_the_audience(answer_k) } }
    choices << { name: '📱 - Phone A Friend', value: -> { phone_a_friend(answer_k) } }
    disable_lifelines(choices)
    choices
  end

  def disable_lifelines(choices)
    unless @lifelines[:ff] == 'avail'
      choices[5][:name] = choices[5][:name].red
      choices[5][:disabled] = ''
    end
    unless @lifelines[:ata] == 'avail'
      choices[6][:name] = choices[6][:name].red
      choices[6][:disabled] = ''
    end
    unless @lifelines[:paf] == 'avail'
      choices[7][:name] = choices[7][:name].red
      choices[7][:disabled] = ''
    end
    choices
  end

  def display_ata
    puts 'Ask The Audience'.center(40, ' ')
    @keys.each do |k, v|
      print "#{k} - #{@lifelines[:ata_graph][v]}%".center(10, ' ')
    end
    puts "\n\n"
  end

  def display_paf
    puts 'Phone A Friend'.center(40, ' ')
    puts "\'I think it's #{@lifelines[:paf_answer]}.\'".center(40, ' ')
    puts
  end

  def check_answer(answer_k, answer_v, input)
    if input == answer_k
      @score += 1
      clear_lifelines
      if @score == 15
        you_win
      end
    else
      puts "Incorrect! The correct answer was #{answer_k} - #{answer_v}."
      you_lose
    end
  end

  def clear_lifelines
    @lifelines[:ff]  = 'used' if @lifelines[:ff]  == 'active'
    @lifelines[:ata] = 'used' if @lifelines[:ata] == 'active'
    @lifelines[:paf] = 'used' if @lifelines[:paf] == 'active'
  end

  def you_win
    system('clear')
    @game_over = true
    score_table
    puts 'CONGRATULATIONS! You won 1 million gems!!!!'.bold
    update_stats(1_000_000)
  end

  def you_lose
    @game_over = true
    prize = '0'
    case @score
    when 10..14
      prize = @@PRIZES[10]
    when 5..9
      prize = @@PRIZES[5]
    end
    puts "You won #{prize} 💎. Better luck next time!"
    update_stats(prize.gsub(',', '').to_i)
  end

  def update_stats(prize)
    @@statistics['games_played'] = @@statistics['games_played'].to_i + 1
    @@statistics['total_winnings'] = @@statistics['total_winnings'].to_i + prize
    @@statistics['hiscore'] = prize if prize > @@statistics['hiscore'].to_i
    puts 'Press Enter to continue.'.green
    gets
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
    prize = @@PRIZES[@score]
    puts "You won #{prize} 💎. Better luck next time!"
    update_stats(prize.gsub(',', '').to_i)
  end

  def score_table
    i = 0
    while i < 16
      puts '|' if [5, 10, 15].include?(i)
      print '|'
      print i == @score ? "#{@@PRIZES[i]} 💎".center(13).bold.yellow : "#{@@PRIZES[i]} 💎".center(13)
      i += 1
    end
    puts '|'
  end

  def fifty_fifty(answer)
    @lifelines[:ff] = 'active'
    @lifelines[:ff_options].slice!(@keys[answer])
    @lifelines[:ff_options].slice!(rand(2))
  end

  def ask_the_audience(answer)
    @lifelines[:ata] = 'active'
    total = 60
    3.times do
      percent = rand(total)
      @lifelines[:ata_graph] << percent + 10
      total -= percent
    end
    @lifelines[:ata_graph] << total + 10
    @lifelines[:ata_graph].shuffle!
    return if rand(2).zero?

    @lifelines[:ata_graph].map!.with_index do |n, index|
      n += index == @keys[answer] ? 30 : -10
    end
  end

  def phone_a_friend(answer)
    @lifelines[:paf] = 'active'
    @lifelines[:paf_answer] = rand(2).zero? ? @keys.keys.sample : answer
  end
end
