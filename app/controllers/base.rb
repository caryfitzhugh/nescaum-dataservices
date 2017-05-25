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
          require 'pry'; binding.pry
          redirect Paths.sign_in_path(return_to: request.fullpath)
        end
      end
    end

    def json(resp)
      content_type :json
      [200, JSON.generate(resp)]
    end
  end
end
