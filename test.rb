# frozen_string_literal: true

require_relative 'lib/app'

RSpec.describe App, '#load' do
  app = App.new
  describe 'on app start: ' do
    it 'should load questions JSON' do
      expect(app.questions.length.positive?).to eq true
    end
    it 'should load statistics JSON' do
      expect(app.statistics.length.positive?).to eq true
    end
  end
end

RSpec.describe Game, '#start' do
    app = App.new
    game = Game.new
end
