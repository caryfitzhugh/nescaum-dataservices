File.expand_path(File.dirname(__FILE__)).tap {|pwd| $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)}
autoload :CONFIG, 'lib/config'
autoload :Paths, 'lib/paths'
autoload :OpenStruct, 'ostruct'
require 'sinatra'
require 'sinatra/base'
require 'logger'
require 'colorize'

require 'sinatra/swagger-exposer/swagger-exposer'
require 'app/controllers/resources_controller'

set :logger, Logger.new(STDOUT)

class App < Sinatra::Application
  register Sinatra::SwaggerExposer
  register Sinatra::Namespace
  general_info(
      {
          version: '0.0.1',
          title: 'NESCAUM Data Services',
          description: 'Data services provided by NESCAUM and other providers',
          license: {
              name: 'Copyright NESCAUM 2017',
              url: 'http://nescaum.org'
          }
      }
  )

  get '/', :no_swagger => true do
    redirect '/index.html'
  end

  namespace "/api" do
    use Controllers::ResourcesController
  end
end
