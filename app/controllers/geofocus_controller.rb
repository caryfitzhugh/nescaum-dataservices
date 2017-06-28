require 'app/controllers/base'
require 'app/models'
module Controllers
  class GeofocusController < Controllers::Base
    type 'NewGeofocus', {
      properties: {
        name: {type: String, description: "Name of the geo-focus"},
      }
    }
    type 'Geofocus', {
      properties: {
        name: {type: String, description: "Name of the geo-focus"},
        id: { type: Integer, description: "ID of the geofocus"},
      }
    }

    endpoint description: "Create Geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "geofocus": ["New Geofocus", :body, true, "NewGeofocus"],
              },
              tags: ["Geofocus", "Curation"]

    post "/geofocus" do
      gf = Geofocus.new(name: params[:parsed_body][:geofocus][:name])
      if gf.save
        json(gf.to_resource)
      else
        err(400, gf.errors.full_messages.join("\n"))
      end
    end

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
