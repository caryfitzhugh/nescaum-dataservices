require 'sinatra'
require 'sinatra/swagger-exposer/swagger-exposer'
require 'json'
require 'app/helpers'

module Controllers
  class Base < Sinatra::Application
    helpers Helpers::Authentication
    register Sinatra::SwaggerExposer

    private
    def self.require_role(role)
      condition do
        unless current_user && (current_user.is_admin? || current_user.is_curator?)
          redirect Paths.root_path
        end
      end
    end

    def json(resp)
      content_type :json
      [200, JSON.generate(resp)]
    end
  end
end
