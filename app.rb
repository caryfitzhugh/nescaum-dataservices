File.expand_path(File.dirname(__FILE__)).tap {|pwd| $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)}
require 'lib/config'
require 'sinatra'
require 'sinatra/base'
require 'logger'
require 'colorize'
require 'ostruct'
require 'lib/paths'

set :logger, Logger.new(STDOUT)

class App < Sinatra::Base
  get '/' do
    redirect '/index.html'
  end
end
