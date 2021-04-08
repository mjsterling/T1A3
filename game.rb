# Initialize a new game instance
class Game < App
  attr_accessor :q_sample, :prizes, :score, :lifelines, :ff_avail, :ff_active,
                :ata_avail, :ata_active, :paf_avail, :paf_active, :game_over, :ff_options

  def initialize
    super

    @q_sample = @@questions.sample(15)
    @score = 0
    @ff_avail = true
    @ata_avail = true
    @paf_avail = true
    @ff_active = false
    @ata_active = false
    @paf_active = false
    @game_over = false
    @keys = { 'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3 }
    @ff_options = [0, 1, 2, 3]
    @ata_graph = []
    @paf_answer = ''

    display_question until @game_over
  end

  def display_question
    system('clear')
    current_q = @q_sample[@score]
    question = current_q['question']
    answer_k = current_q['answer']
    answer_v = current_q[answer_k]
    score_table
    puts "\nQuestion #{@score + 1}: #{question}\n".bold
    display_lifelines
    prompt = prompt_instance
    prompt.select('Select an option:'.bold, generate_choices(current_q, answer_k, answer_v), per_page: 8)
  end

  def display_lifelines
    if ata_active
      puts 'Ask The Audience'.center(40, ' ')
      @keys.each do |k, v|
        print "#{k} - #{@ata_graph[v]}%".center(10, ' ')
      end
      puts "\n\n"
    end
    if paf_active
      puts 'Phone A Friend'.center(40, ' ')
      puts "\'I think it's #{@paf_answer}.\'".center(40, ' ')
      puts
    end
  end

  def generate_choices(current_q, answer_k, answer_v)
    choices = []
    @keys.each do |k, v|
      choices << { name: "#{k} - #{current_q[k]}", value: -> { check_answer(answer_k, answer_v, k) } }
      choices.last[:name] = choices.last[:name].red if @ff_options.include?(v)
      choices.last[:disabled] = '' if @ff_options.include?(v)
    end
    choices << { name: "Walk away with #{@@PRIZES[@score]} 💎", value: -> { confirm_walk_away } }
    choices << { name: ' ½ - 50/50', value: -> { fifty_fifty(answer_k) } }
    choices << { name: '🗨  - Ask The Audience', value: -> { ask_the_audience(answer_k) } }
    choices << { name: '📱 - Phone A Friend', value: -> { phone_a_friend(answer_k) } }
    disable_lifelines(choices)
  end

  def disable_lifelines(choices)
    unless ff_avail
      choices[5][:name] = choices[5][:name].red
      choices[5][:disabled] = ''
    end
    unless ata_avail
      choices[6][:name] = choices[6][:name].red
      choices[6][:disabled] = ''
    end
    return if paf_avail

    choices[7][:name] = choices[7][:name].red
    choices[7][:disabled] = ''
  end

  def check_answer(answer_k, answer_v, input)
    if input == answer_k
      @score += 1
      clear_lifelines
      if @score == 15
        @game_over = true
        you_win
      end
    else
      @game_over = true
      puts "Incorrect! The correct answer was #{answer_k} - #{answer_v}."
      you_lose
    end
  end

  def clear_lifelines
    @ff_active = false
    @ata_active = false
    @paf_active = false
  end

  def you_win
    system('clear')
    score_table
    puts 'CONGRATULATIONS! You won 1 million gems!!!!'.bold
    update_stats(1_000_000)
  end

  def you_lose
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
    @ff_avail = false
    @ff_active = true
    @ff_options = @keys.values
    @ff_options.slice!(@keys[answer])
    @ff_options.slice!(rand(2))
  end

  def ask_the_audience(answer)
    @ata_active = true
    @ata_avail = false
    total = 60
    3.times do
      percent = rand(total)
      @ata_graph << percent + 10
      total -= percent
    end
    @ata_graph << total + 10
    @ata_graph.shuffle!
    return if rand(2).zero?

    @ata_graph.each_with_index do |n, index|
      n + index == @keys[answer] ? 30 : -10
    end
  end

  def phone_a_friend(answer)
    @paf_active = true
    @paf_avail = false
    @paf_answer = rand(2).zero? ? @keys.keys.sample : answer
  end
end
