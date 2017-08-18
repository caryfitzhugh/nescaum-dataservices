File.expand_path(File.dirname(__FILE__)).tap {|pwd| $LOAD_PATH.unshift(pwd) unless $LOAD_PATH.include?(pwd)}
require 'lib/utils'
require 'lib/ilike'
autoload :CONFIG, 'lib/config'
autoload :Paths, 'lib/paths'
autoload :OpenStruct, 'ostruct'
require 'sinatra'
require 'sinatra/base'
require 'logger'
require 'colorize'
require 'rack/cors'

require 'sinatra/swagger-exposer/swagger-exposer'
require 'app/controllers/resources_controller'
require 'app/controllers/collections_controller'
require 'app/controllers/authentication_controller'
require 'app/controllers/geofocus_controller'
require 'app/controllers/actions_controller'
require 'app/controllers/users_controller'
require 'app/helpers'

require 'lib/cloudsearch'

set :logger, Logger.new(STDOUT)
set :views, Proc.new { File.join(root, "app", "views") }
set :method_override, true
set :public_folder, File.dirname(__FILE__) + '/public'

class NDSApp < Sinatra::Application
  register Sinatra::SwaggerExposer
  use Rack::Session::Cookie, :key => 'rack.session',
                             :expire_after => 60 * 60 * 24, # 1 day
                             :secret => ENV["SESSION_SECRET"],
                             :old_secret => ENV["OLD_SESSION_SECRET"]

  use Rack::Cors do
    allow do
      origins '*'
      resource "*", methods: :any
    end
  end

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
  use Controllers::GeofocusController
  use Controllers::AuthenticationController
  use Controllers::CollectionsController
  use Controllers::ActionsController
  use Controllers::UsersController

  get "/", :no_swagger => true do
    redirect '/index.html'
  end

  get '/data/*' , :no_swagger => true do
    send_file File.join(File.dirname(__FILE__), 'data', params[:splat])
  end

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"

    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    200
  end
end
