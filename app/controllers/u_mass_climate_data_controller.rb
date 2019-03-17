require 'app/controllers/base'
require 'app/models'

module Controllers
  class UMassClimateDataController < Controllers::Base
 VARIABLE_NAMES = %w(avgtemp
                     consdrydays
                     cooldegdays
                     growdegdays
                     heatdegdays
                     maxtemp
                     mintemp
                     precip
                     precipgt1
                     precipgt2
                     precipgt4
                     tempgt100
                     tempgt90
                     tempgt95
                     templt0
                     templt32)

    type 'UMASSProjectedDataFeaturePropertyValue', {
      properties: {
        year: { type: Integer, description: "Year"},
        delta_low: { type: Float},
        delta_high: { type: Float},
      }
    }

    type 'UMASSProjectedDataFeaturePropertyDetail', {
      properties: {
        season: { type: String, description: "Season"},
        values: { type: ["UMASSProjectedDataFeaturePropertyValue"]},
      }
    }

    type 'UMASSProjectedDataFeatureProperties', {
      properties: {
        variable_name: { type: String, description: "Variable of data: " + VARIABLE_NAMES.to_json},
        geomtype: { type: String, description: "Geometry type [basin, county]"},
        name: { type: String, description: "Data description"},
        uid: { type: String, description: "UID of data location"},
        data: { type: ['UMASSProjectedDataFeaturePropertyDetail'], description: "The Data"}
      }
    }

    type 'UMASSProjectedDataFeature', {
      properties: {
        type: { type: String, description: "type of feature"},
        geometry: { type: String, description: "Geojson of the feature"},
        properties: { type: "UMASSProjectedDataFeatureProperties"},
      }
    }

    type 'UMASSProjectedDataGeoJSON', {
      properties: {
        type: { type: String, description: "Type of GeoJSON"},
        features: { type: ["UMASSProjectedDataFeature"], description: "Features"}
      }
    }

    endpoint description: "Get Projected UMass Data",
              responses: standard_errors( 200 => "UMASSProjectedDataGeoJSON"),
              parameters: {
                "variable_name"  => ["Parameter to return (mint, maxt, etc.)", :query, false, String],
                "geomtype"  => ["Geometry type to return (basin/county)", :query, false, String],
                # "geojson"  => ["GeoJson should be included flag", :query, false, String],
              },
              tags: ["UMass", "Climate Data", "Public"]

    get "/umass/projected/?" do
      cross_origin

      features = UMASSData.projected(params['variable_name'],
                                      params['geojson'] =~ /true/i,
                                      params['geomtype'])
      json({
        "type": "FeatureCollection",
        "features": features
      })
    end
  end
end
