Gem::Specification.new do |s|
  s.name = "app47"
  s.version = '0.1.0'
  s.summary = 'App47 API library'
  s.description = 'A gem that provides wrappers for working with the App47 APIs'
  s.author = "Scott A. Guyer"
  s.email = 'support@app47.com'
  s.files = ['lib/App47.rb']
  s.homepage = 'http://app47.com/wiki/doku.php?id=home'
  s.add_runtime_dependency 'rest-client', '~> 1.6.7'
  s.add_runtime_dependency 'json', '~> 1.6.5'
end

