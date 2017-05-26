require 'app/controllers/base'
module Controllers
  class ResourcesController < Controllers::Base
    type 'Resource', {
      required: [:title, :docid],
      properties: {
        abstract: { type: String, example: "Abstract From Article. Lorem Lorem"},
        actions:  { type: [String], example: "[\"Emissions Reduction\", \"Emissions Reduction::multiple emissions reduction actions\"]"},
        authors:  { type: [String], example: "[\"C.S. Lewis\", \"Northeast Regional Climate Center (NRCC)\"]"},
        climate_changes:  { type: [String], example: "[\"Precipitation\", \"Precipitation::Heavy Precipitation Events\"]"},
        docid:  { type: String, example: "maps::44"},
        effects: { type: [String], example: "[\"Specific Vulnerability\", \"Specific Vulnerability::Coastal Property Damage\"]"},
        formats: { type: [String], example: "[\"Documents\", \"Documents::Report\"]"},
        geofocus: { type: [String], example: "[\"Ulster County, NY\", \"Westchester County, NY\", \"Maine Coastland\"]"},
        state:    { type: [String], example: "[\"NY\", \"MA\"]"},
        keywords: { type: [String], example: "[\"dams\", \"floods\", \"land cover change\"]"},
        latlon: { type: [Float], example: "[10.123, 10.123]"},
        links:  { type: [String], example: "[\"pdf::http://123.com/pdf\", \"weblink::http://123.com/abc.html\"]"},
        sectors: { type: [String], example: "[\"Ecosystems\", \"Water Resources\"]"},
        strategies: { type: [String], example: "[\"Adaptation\"]"},
        title: { type: String, example: "To be determined, the data abstracts needed for a search result page"},
      }
    }

    endpoint description: "Search for resources",
              responses: standard_errors( 200 => [["Resource"]]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Resources", "Public"]

    get "/resources" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      resources = Cloudsearch.search(size: per_page, start: (page - 1) * per_page)
      json(resources.to_a)
    end
  end
end
