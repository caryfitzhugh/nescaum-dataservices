require 'app/controllers/base'
module Controllers
  class ResourcesController < Controllers::Base
    type 'Resource', {
      #required: [:title],
      properties: {
        title: { type: String, example: "To be determined, the data abstracts needed for a search result page"},
      }
    }

    endpoint description: "Lookup and manage resources",
              responses: standard_errors( 200 => [["Resource"]]),
              parameters: {
                "facet_sector": ["Set of sector values to filter against", :query, false, [Integer]],
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Resources", "Public"]

    get "/resources" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      resources = []
      json(resources.to_a)
    end
  end
end
