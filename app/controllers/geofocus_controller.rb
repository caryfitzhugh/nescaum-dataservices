require 'app/controllers/base'
require 'app/models'
module Controllers
  class GeofocusController < Controllers::Base
    type 'Geofocus', {
      properties: {
        name: {type: String, description: "Name of the geo-focus"},
        id: { type: Integer, description: "ID of the geofocus"},
      }
    }
    endpoint description: "Search against all geofocus entries",
              responses: standard_errors( 200 => [["Geofocus"]]),
              parameters: {
                "names": ["Name of the geofocus to search for", :query, true, String],
              },
              tags: ["Resources", "Public"]

    get "/geofocus/search" do
      json([])
    end
  end
end
