require 'rubygems'
require 'bundler'

Bundler.require

require './nds_app'

map '/' do
  run NDSApp
end
