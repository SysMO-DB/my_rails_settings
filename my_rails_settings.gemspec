Gem::Specification.new do |s|
  s.name        = 'my_rails_settings'
  s.version     = '1.1.0'
  s.date        = '2016-01-14'
  s.summary     = "A Gem that makes managing a table of global key, value pairs easy"
  s.authors     = ["Alex Wayne","Quyen Nguyen","Finn Bacall"]
  s.email       = 'nttqa22001@yahoo.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/SysMO-DB/my_rails_settings'
  s.require_paths = ["lib"]
  s.add_development_dependency 'rails', '>= 4.0.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'test-unit', '~> 3.0'
end
