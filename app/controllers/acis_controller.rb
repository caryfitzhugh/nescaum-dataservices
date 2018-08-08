require 'app/controllers/base'
require 'app/models'

module Controllers
  class AcisController < Controllers::Base
    type 'AcisDataFeaturePropertyDetail', {
      properties: {
        year: { type: Number, description: "Year"},
        delta_low: { type: Float},
        delta_high: { type: Float},
      }
    }
    type 'AcisDataFeatureProperties', {
      properties: {
        variable_name: { type: String, description: "Variable of data: " + [
                    'mint',
                    'maxt',
                    'maxt_gt_95',
                    'mint_lt_32',
                    'avgt',
                    'gdd',
                    'hdd',
                    'maxt_gt_90',
                    'pcpn_gt_2',
                    'maxt_gt_100',
                    'mint_lt_0',
                    'pcpn_gt_1',
                    'cdd',
                    'pcpn'].to_json},
        geomtype: { type: String, description: "Geometry type [basin, county]"},
        name: { type: String, description: "Data description"},
        uid: { type: String, description: "UID of data location"},
        data: { type: ['AcisDataFeaturePropertyDetail'], description: "The Data"}
      }
    }

    type 'AcisDataFeature', {
      properties: {
        type: { type: String, description: "type of feature"},
        geometry: { type: String, description: "Geojson of the feature"},
        properties: { type: "AcisDataFeatureProperties"},
      }
    }

    type 'AcisDataGeoJSON', {
      properties: {
        type: { type: String, description: "Type of GeoJSON"},
        features: { type: ["AcisDataFeature"], description: "Features"}
      }
    }


    endpoint description: "Get Observed ACIS Data",
              responses: standard_errors( 200 => "AcisDataGeoJSON"),
              parameters: {
                "variable_name"  => ["Parameter to return (mint, maxt, etc.)", :query, false, String],
                "geomtype"  => ["Geometry type to return (basin/county)", :query, false, String],
                "geojson"  => ["GeoJson should be included flag", :query, false, String],
              },
              tags: ["ACIS", "Climate Data", "Public"]

    get "/acis/ny/observed/?" do
      cross_origin

      features = AcisData.ny_observed(params['variable_name'],
                                      params['geojson'] =~ /true/i,
                                      params['geomtype'] || 'basin')
    end
  end
end
