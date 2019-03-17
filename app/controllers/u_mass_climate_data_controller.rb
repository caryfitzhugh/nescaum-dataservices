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

    type 'UMassProjectedDataFeaturePropertyValue', {
      properties: {
        year: { type: Integer, description: "Year"},
        delta_low: { type: Float},
        delta_high: { type: Float},
      }
    }

    type 'UMassProjectedDataFeaturePropertyDetail', {
      properties: {
        season: { type: String, description: "Season"},
        values: { type: ["UMassProjectedDataFeaturePropertyValue"]},
      }
    }

    type 'UMassProjectedDataFeatureProperties', {
      properties: {
        variable_name: { type: String, description: "Variable of data: " + VARIABLE_NAMES.to_json},
        geomtype: { type: String, description: "Geometry type [basin, county]"},
        name: { type: String, description: "Data description"},
        uid: { type: String, description: "UID of data location"},
        data: { type: ['UMassProjectedDataFeaturePropertyDetail'], description: "The Data"}
      }
    }

    type 'UMassProjectedDataFeature', {
      properties: {
        type: { type: String, description: "type of feature"},
        geometry: { type: String, description: "Geojson of the feature"},
        properties: { type: "UMassProjectedDataFeatureProperties"},
      }
    }

    type 'UMassProjectedDataGeoJSON', {
      properties: {
        type: { type: String, description: "Type of GeoJSON"},
        features: { type: ["UMassProjectedDataFeature"], description: "Features"}
      }
    }

    endpoint description: "Get Projected UMass Data",
              responses: standard_errors( 200 => "UMassProjectedDataGeoJSON"),
              parameters: {
                "variable_name"  => ["Parameter to return (mint, maxt, etc.)", :query, false, String],
                "geomtype"  => ["Geometry type to return (basin/county)", :query, false, String],
                # "geojson"  => ["GeoJson should be included flag", :query, false, String],
              },
              tags: ["UMass", "Climate Data", "Public"]

    get "/umass/projected/?" do
      cross_origin

      features = UMassClimateData.projected(params['variable_name'],
                                      params['geojson'] =~ /true/i,
                                      params['geomtype'])
      json({
        "type": "FeatureCollection",
        "features": features
      })
    end
  end
end
