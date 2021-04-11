# frozen_string_literal: true

require_relative 'lib/app'

RSpec.describe App do
  app = App.new
  describe 'on app start: ' do
    it 'should create a hash of questions' do
      expect(app.questions.length.positive?).to eq true
    end
    it 'should load hiscores/statistics' do
      expect(app.statistics.length.positive?).to eq true
    end
    it 'should find all correct files' do
      expect(app.check_dependencies).to eq nil
    end
  end
end

RSpec.describe Game do
  game = Game.new
  describe 'on game load:' do
    it 'should take a sample of 15 questions' do
      expect(game.q_sample.length).to eq 15
    end
    it 'should return unique questions' do
      duplicate = false
      14.times do |i|
        duplicate = true if game.q_sample[14] == game.q_sample[i]
      end
      expect(duplicate).to eq false
    end
  end

  describe 'during game:' do
    it 'should calculate the correct score' do
      game.score = 3
      expect(game.prizes[game.score - 1]).to eq '1,000'
      game.score = 14
      expect(game.prizes[game.score - 1]).to eq '250,000'
    end
    it 'should dynamically generate a menu' do
      current_q = game.q_sample[game.score]
      game.lifelines[:ata][:status] = true
      choices = game.gen_menu(current_q)
      expect(choices.length).to eq 8
      expect(choices[0][:name]).to eq "A - #{current_q['A']}"
      expect(choices[6][:disabled]).to be_a(String)
    end
  end

  describe 'end of game:' do
    it 'should break when game over' do
      game.game_over = true
      expect(game.start).to eq nil
    end
    it 'should save highscores correctly' do
      game.update_stats(69_420)
      expect(game.statistics['hiscore']).to eq 69_420
    end
  end
end
