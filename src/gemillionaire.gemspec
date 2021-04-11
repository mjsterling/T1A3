Gem::Specification.new do |s|
  s.name = 'gemillionaire'
  s.version     = '1.0.3'
  s.summary     = 'Gemillionaire'
  s.description = 'Who Wants To Be A Millionaire terminal-based game'
  s.authors     = ['Matthew Sterling']
  s.email       = 'mjsterling93@gmail.com'
  s.files       = ["#{__dir__}/lib/gemillionaire.rb", "#{__dir__}/lib/gemillionaire/app.rb", "#{__dir__}/lib/gemillionaire/game.rb",
                   "#{__dir__}/lib/gemillionaire/hiscores.json", "#{__dir__}/lib/gemillionaire/questions.json"]
  s.homepage    =
    'https://rubygems.org/gems/gemillionaire'
  s.license = 'MIT'
end
