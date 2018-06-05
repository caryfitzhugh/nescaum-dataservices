require 'app/controllers/base'
require 'app/models'

module Controllers
  class ClimateDeltasController < Controllers::Base
    type 'ClimateDeltaFeature', {
      properties: {
        type: { type: String, description: "Feature Type"},
        geometry: { type: String, description: "Geojson of the geofocus"},
        properties: { type: String, description: "Properties"}
      }
    }

    type 'ClimateDeltaGeoJSON', {
      properties: {
        type: { type: String, description: "Type of GeoJSON"},
        features: { type: ["ClimateDeltaFeature"], description: "Features"}
      }
    }

    endpoint description: "Get Climate Data",
              responses: standard_errors( 200 => "ClimateDeltaGeoJSON"),
              parameters: {
                "parameter"  => ["Parameter name to return data on", :query, false, String],
                "geojson" => ["Return geometries as well", :query, false, 'boolean'],
                "state" => ["State to return data for", :path, true, String],
              },
              tags: ["Climate Data", "Public"]

    get "/climate-data/:state/?" do
      features = []
      json({
        "type" => "FeatureCollection",
        "features" => features
      })
    end
  end
end
