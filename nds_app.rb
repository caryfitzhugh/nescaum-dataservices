File.expand_path(File.dirname(__FILE__)).tap {|pwd| $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)}
require 'lib/utils'
autoload :CONFIG, 'lib/config'
autoload :Paths, 'lib/paths'
autoload :OpenStruct, 'ostruct'
require 'sinatra'
require 'sinatra/base'
require 'logger'
require 'colorize'

require 'sinatra/swagger-exposer/swagger-exposer'
require 'app/controllers/resources_controller'
require 'app/controllers/curation_controller'
require 'app/controllers/authentication_controller'
require 'app/helpers'

require 'lib/cloudsearch'

set :logger, Logger.new(STDOUT)
set :views, Proc.new { File.join(root, "app", "views") }
set :method_override, true

class NDSApp < Sinatra::Application
  register Sinatra::SwaggerExposer
  use Rack::Session::Cookie, :key => 'rack.session',
                           :expire_after => 60 * 60 * 24, # 1 day
                           :secret => ENV["SESSION_SECRET"],
                           :old_secret => ENV["OLD_SESSION_SECRET"]
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
  helpers Helpers::Authentication

  use Controllers::ResourcesController
  use Controllers::AuthenticationController
  use Controllers::CurationController

  get "/", :no_swagger => true do
    redirect '/index.html'
  end
end
