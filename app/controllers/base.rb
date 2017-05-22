require 'sinatra'
require 'sinatra/swagger-exposer/swagger-exposer'
require 'json'
module Controllers
  class Base < Sinatra::Application
    register Sinatra::SwaggerExposer

    private

    def json(resp)
      content_type :json
      [200, JSON.generate(resp)]
    end
  end
end
