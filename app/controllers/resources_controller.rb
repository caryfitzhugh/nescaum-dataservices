require 'app/controllers/base'
require 'app/controllers/sectors_controller'
require 'app/models'

module Controllers
  class ResourcesController < Controllers::Base
    type 'Resource', {
      required: [:name, :document_url],
      properties: {
        id: {type: Integer, example: "1"},
        name: { type: String, example: "Document determining temperature change ..."},
        document_url: { type: String, example: "http://s3.document.com"},
      }
    }

    endpoint description: "Lookup and manage resources",
              responses: standard_errors( 200 => [["Resource"]]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Resources", "Public"]

    get "/resources" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      resources = Models::Resource.all(offset: page - 1, limit: per_page)
      json(resources.to_a)
    end
  end
end
