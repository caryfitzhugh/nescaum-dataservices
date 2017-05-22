require 'sinatra/swagger-exposer/swagger-exposer'
require 'json'

module Controllers
  class ResourcesController < Sinatra::Application

    type 'Resources', {
      properties: {
        name: { type: String, example: "Document determining temperature change ..."},
        document_url: { type: String, example: "http://s3.document.com"},
      }
    }

    endpoint description: "Lookup and manage resources",
              responses: { 200 => ["Resources"]},
              tags: "Resources"
    get '/resources' do
      json({name: "HI", document_url: "http://google.com/doc"})
    end
  end
end
