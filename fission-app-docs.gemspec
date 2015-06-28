$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-app-docs/version'
Gem::Specification.new do |s|
  s.name = 'fission-app-docs'
  s.version = FissionApp::Docs::VERSION.version
  s.summary = 'Fission App Documentation Pages'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-app-docs'
  s.description = 'Fission application documentation pages'
  s.require_path = 'lib'
  s.files = Dir['{lib,app,config}/**/**/*'] + %w(fission-app-docs.gemspec)
  s.add_dependency 'kramdown-rails'
end
