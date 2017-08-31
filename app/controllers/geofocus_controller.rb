require 'app/controllers/base'
require 'app/models'
module Controllers
  class GeofocusController < Controllers::Base
    type 'IdGeoJSON', {
      properties: {
        geometry: { type: String, description: "Geojson of the geofocus"}
      }
    }

    type 'BulkGeoJSON', {
      properties: {
        type: { type: String, description: "FeatureCollection"},
        features: { type: ["IdGeoJSON"], description: "Bulk Geojson records"}
      }
    }

    type 'GeoJSON', {

    }

    type 'NewGeofocus', {
      properties: {
        name: {type: String, description: "Name of the geo-focus"},
        geom: {type: String, description: "Geojson representation of the point / feature of this geofocus"},
        type: {type: String, description: "Type of the geofocus (i.e. City, Town, County, State, Region, etc)"},
        uid: {type: String, description: "UID of the geofocus"},
      }
    }

    type 'Geofocus', {
      properties: {
        id: {type: Integer, description: "Geofocus ID"},
        name: {type: String, description: "Name of the geo-focus"},
        type: {type: String, description: "Type of the geofocus (i.e. City, Town, County, State, Region, etc)"},
        uid: {type: String, description: "UID of the geofocus"},
        geom: {type: String, description: "Geojson representation of the point / feature of this geofocus"},
      }
    }

    type 'GeofocusIndex', {
      properties: {
        total: {type: Integer},
        page: {type: Integer},
        per_page: {type: Integer},
        geofocuses: {type: ["Geofocus"]}
      }
    }

    endpoint description: "Find specific geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "uid": ["UID of the geofocus to search for", :query, true, String],
                "type": ["Type of the geofocus to search for", :query, true, String],
              },
              tags: ["Geofocus", "Public"]

    get "/geofocuses/find/?" do
      cross_origin
      gf = Geofocus.first(:type => params[:type], :uid => params[:uid])
      if gf
        json(gf.to_resource)
      else
        not_found("Geofocus", params[:uid])
      end
    end

    endpoint description: "Get GeoJSON for a set of geofocuses",
              responses: standard_errors( 200 => ["BulkGeoJSON"]),
              parameters: {
                "ids": ["Ids to retrieve, split by ','", :query, true, String],
              },
              tags: ["Geofocus", "Public"]

    get "/geofocuses/bulk_geojson/?" do
      cross_origin
      ids = params[:ids].split(',').map(&:to_i)
      gfs = Geofocus.all(id: ids)
      if gfs.length == ids.length
        content_type :json
        geojsons = gfs.map(&:to_geojson)

        json({ type: "FeatureCollection", features: geojsons })
      else
        not_found("Geofocus", params[:ids])
      end
    end


    endpoint description: "Create Geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "geofocus": ["New Geofocus", :body, true, "NewGeofocus"],
              },
              tags: ["Geofocus", "Curator"]

    post "/geofocuses", require_role: :curator do
      gf = Geofocus.new(to_geofocus_attrs(params[:parsed_body][:geofocus]))
      if gf.save
        Action.track!(gf, current_user, "Created")
        json(gf.to_resource)
      else
        err(400, gf.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Get a geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "id": ["ID of the geofocus to retrieve", :path, true, Integer],
              },
              tags: ["Geofocus", "Public"]

    get "/geofocuses/:id" do
      cross_origin
      gf = Geofocus.first(id: params[:id])

      if gf
        json(gf.to_resource)
      else
        not_found("Geofocus", params[:id])
      end
    end

    endpoint description: "Update a geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "id": ["ID of the geofocus to update", :path, true, Integer],
                "geofocus": ["Data to update", :body, true, "NewGeofocus"]
              },
              tags: ["Geofocus", "Curator"]

    put "/geofocuses/:id" do
      gf = Geofocus.first(id: params[:id])

      if gf
        if gf.update(to_geofocus_attrs(params[:parsed_body][:geofocus]))
          Action.track!(gf, current_user, "Updated")
          json(gf.to_resource)
        else
          err(400, gf.errors.full_messages.join("\n"))
        end
      else
        not_found("Geofocus", params[:id])
      end
    end

    endpoint description: "Delete a geofocus",
              responses: standard_errors( 200 => ["Geofocus"]),
              parameters: {
                "id": ["ID of the geofocus to delete", :path, true, Integer],
              },
              tags: ["Geofocus", "Curator"]

    delete "/geofocuses/:id", require_role: :curator do
      gf = Geofocus.first(id: params[:id])

      if gf
        if gf.destroy
          Action.track!(gf, current_user, "Deleted")
          json(gf.to_resource)
        else
          err(400, gf.errors.full_messages.join("\n"))
        end
      else
        not_found("Geofocus", params[:id])
      end
    end


    endpoint description: "Search against all geofocus entries",
              responses: standard_errors( 200 => ["GeofocusIndex"]),
              parameters: {
                "q": ["Name of the geofocus to search for", :query, false, String],
                "type": ["Type of the geofocus to search for", :query, false, String],
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 5000}],
              },
              tags: ["Geofocus", "Public"]

    get "/geofocuses/?" do
      cross_origin
      per_page = params[:per_page] || 50
      page = params[:page] || 1

      gfs = Geofocus.all(:order => [:name.asc])

      if params[:q]
        gfs = gfs.all(:name.ilike => "%#{params[:q]}%")
      end

      if params[:type]
        gfs = gfs.all(:type => params[:type])
      end

      count = gfs.count
      gfs = gfs.all(:limit => per_page, :offset => per_page * (page - 1))

      json(
        total: count,
        page: page,
        per_page: per_page,
        geofocuses: gfs.map(&:to_resource)
      )
    end

    endpoint description: "Get GeoJSON for a geofocus",
              responses: standard_errors( 200 => ["GeoJSON"]),
              parameters: {
                "id": ["Id to retrieve", :path, true, Integer],
              },
              tags: ["Geofocus", "Public"]

    get "/geofocuses/:id/geojson/?" do
      cross_origin
      gf = Geofocus.first(:id => params[:id])
      if gf
        json(gf.to_geojson)
      else
        not_found("Geofocus", params[:id])
      end
    end

    private

    def to_geofocus_attrs(param)
      attrs = param
      if attrs[:geom]
        attrs[:geom] = GeoRuby::SimpleFeatures::Geometry.from_geojson(attrs[:geom])#.geometry
        attrs[:geom] = attrs[:geom].geometry if attrs[:geom].respond_to?(:geometry)
      end
      attrs
    end
  end
end
