Gem::Specification.new do |s|
  s.name = "app47"
  s.version = '0.1.0.pre'
  s.summary = 'App47 API library'
  s.description = 'A gem that provides wrappers for working with the App47 APIs'
  s.author = "Scott A. Guyer"
  s.email = 'support@app47.com'
  s.files = %w( lib/app47/builds_client.rb
      lib/app47/users_client.rb
      lib/app47/client.rb
    lib/app47/cli/app.rb
    lib/app47/cli/builds.rb
    lib/app47/cli/command.rb
    lib/app47/cli/symbol_hash.rb
    lib/app47/cli/users.rb
    lib/app47/cli/usage_error.rb
    lib/app47/groups_client.rb
    lib/app47/cli/groups.rb
    lib/app47/cli/json_helpers.rb )
  s.homepage = 'http://app47.com/wiki/doku.php?id=home'
  s.add_runtime_dependency 'rest-client', '~> 1.6.7'
  s.add_runtime_dependency 'json', '~> 1.6.5'
  s.add_runtime_dependency 'roo', '~> 1.10.1'
  s.executables << 'app47'
end

