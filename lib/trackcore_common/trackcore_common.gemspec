Gem::Specification.new do |s|
  s.name        = 'trackcore_common'
  s.version     = '0.1.0'
  s.summary     = 'Common functionality for Trackcore services'
  s.authors     = ['Your Team']
  s.files       = Dir['{lib}/**/*']
  
  s.add_dependency 'jwt'
  s.add_dependency 'oj'
  s.add_dependency 'request_store'
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
end
