require 'app/controllers/base'
require 'app/models'
module Controllers
  class GeofocusController < Controllers::Base
    type 'NewGeofocus', {
      properties: {
        name: {type: String, description: "Name of the geo-focus"},
      }
    }

    endpoint description: "Create Geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "geofocus": ["New Geofocus", :body, true, "NewGeofocus"],
              },
              tags: ["Geofocus", "Curation"]

    post "/geofocuses", require_role: :curator do
      gf = Geofocus.new(name: params[:parsed_body][:geofocus][:name])
      if gf.save
        json(gf.to_resource)
      else
        err(400, gf.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Delete a geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "id": ["ID of the geofocus to delete", :path, true, Integer],
              },
              tags: ["Resources", "Curation"]

    delete "/geofocuses/:id", require_role: :curator do
      gf = Geofocus.first(id: params[:id])

      if gf
        if gf.destroy
          json(gf.to_resource)
        else
          err(400, gf.errors.full_messages.join("\n"))
        end
      else
        not_found("Geofocus", params[:id])
      end
    end

    endpoint description: "Search against all geofocus entries",
              responses: standard_errors( 200 => [["Geofocus"]]),
              parameters: {
                "q": ["Name of the geofocus to search for", :query, true, String],
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Resources", "Public"]

    get "/geofocuses" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1

      gfs = Geofocus.all(:name.like => "%#{params[:q]}%")
      json(gfs.map(&:to_resource))
    end
  end
end
