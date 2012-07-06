require 'bundler'
Bundler.require

require File.join(File.dirname(__FILE__), 'lib', 'mogreet', 'app')

map '/' do    
  run Mogreet::App
end
