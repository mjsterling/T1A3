# Initialize a new game instance
class Game < App
  attr_accessor :q_sample, :score, :lifelines, :game_over, :keys

  def initialize
    super

    @q_sample = @@questions.sample(15)
    @score = 0
    @lifelines = { ff: 'avail', ff_options: [0, 1, 2, 3], ata: 'avail', ata_graph: gen_graph, paf: 'avail', paf_answer: [] }
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
    prompt.select('Select an option:'.bold, gen_choices(current_q), per_page: 8)
  end

  def gen_choices(current_q)
    answer_k = current_q['answer']
    answer_v = current_q[answer_k]
    choices = gen_answers(current_q, answer_k, answer_v)
    gen_lifelines(choices, answer_k)
    disable_lifelines(choices)
    choices
  end

  def gen_answers(current_q, answer_k, answer_v)
    choices = @keys.keys.map do |k|
      { name: "#{k} - #{current_q[k]}", value: -> { check_answer(answer_k, answer_v, k) } }
    end
    disable_answers(choices) if @lifelines[:ff] == 'active'
    choices
  end

  def disable_answers(choices)
    @keys.each_value do |v|
      if @lifelines[:ff_options].include?(v)
        choices[v][:name] = choices[v][:name].red
        choices[v][:disabled] = ''
      end
    end
    choices
  end

  def gen_lifelines(choices, answer_k)
    choices << { name: "Walk away with #{@@PRIZES[@score]} 💎", value: -> { confirm_walk_away } }
    choices << { name: ' ½ - 50/50', value: -> { fifty_fifty(answer_k) } }
    choices << { name: '🗨  - Ask The Audience', value: -> { ask_the_audience(answer_k) } }
    choices << { name: '📱 - Phone A Friend', value: -> { phone_a_friend(answer_k) } }
    choices
  end

  def disable_lifelines(choices)
    [@lifelines[:ff], @lifelines[:ata], @lifelines[:paf]].each_with_index do |lifeline, index|
      unless lifeline == 'avail'
        choices[index + 5][:name] = choices[index + 5][:name].red
        choices[index + 5][:disabled] = ''
      end
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
    return you_lose(answer_k, answer_v) unless input == answer_k

    @score += 1
    clear_lifelines
    you_win if @score == 15
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

  def you_lose(answer_k, answer_v)
    puts "Incorrect! The correct answer was #{answer_k} - #{answer_v}."
    @game_over = true
    prize = @@PRIZES[@score / 5 * 5]
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

  def gen_graph
    total = 60
    3.times do
      percent = rand(total)
      @lifelines[:ata_graph] << percent + 10
      total -= percent
    end
    @lifelines[:ata_graph] << total + 10
    @lifelines[:ata_graph].shuffle!
  end

  def ask_the_audience(answer)
    @lifelines[:ata] = 'active'
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
