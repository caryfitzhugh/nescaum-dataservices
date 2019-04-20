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

    type 'UMassProjected30yrDataFeaturePropertyValue', {
      properties: {
        year: { type: Integer, description: "Year"},
        delta_low: { type: Float},
        delta_high: { type: Float},
      }
    }

    type 'UMassProjected30yrDataFeaturePropertyDetail', {
      properties: {
        season: { type: String, description: "Season"},
        values: { type: ["UMassProjected30yrDataFeaturePropertyValue"]},
      }
    }

    type 'UMassProjected30yrDataFeatureProperties', {
      properties: {
        variable_name: { type: String, description: "Variable of data: " + VARIABLE_NAMES.to_json},
        geomtype: { type: String, description: "Geometry type [basin, county]"},
        name: { type: String, description: "Data description"},
        uid: { type: String, description: "UID of data location"},
        data: { type: ['UMassProjected30yrDataFeaturePropertyDetail'], description: "The Data"}
      }
    }

    type 'UMassProjected30yrDataFeature', {
      properties: {
        type: { type: String, description: "type of feature"},
        geometry: { type: String, description: "Geojson of the feature"},
        properties: { type: "UMassProjected30yrDataFeatureProperties"},
      }
    }

    type 'UMassProjected30yrDataGeoJSON', {
      properties: {
        type: { type: String, description: "Type of GeoJSON"},
        features: { type: ["UMassProjected30yrDataFeature"], description: "Features"}
      }
    }

    endpoint description: "Get Projected UMass Data",
              responses: standard_errors( 200 => "UMassProjected30yrDataGeoJSON"),
              parameters: {
                "variable_name"  => ["Parameter to return (mint, maxt, etc.)", :query, false, String],
                "geomtype"  => ["Geometry type to return (basin/county)", :query, false, String],
                # "geojson"  => ["GeoJson should be included flag", :query, false, String],
              },
              tags: ["UMass", "Climate Data", "Public"]
    get "/umass/projected/?" do
      cross_origin

      features = UMassClimateData30yr.projected(params['variable_name'],
                                      params['geojson'] =~ /true/i,
                                      params['geomtype'])
      json({
        "type": "FeatureCollection",
        "features": features
      })
    end

    type 'UMassDatagrapherData', {
      properties: {
      }
    }

    endpoint description: "Get 5Yr Observed and Projected UMass Data",
              responses: standard_errors( 200 => "UMassDatagrapherData"),
              parameters: {
                "variable_name"  => ["CD , TG, TX, ... R1in, etc", :query, false, String],
                "area_type"  => ["Geometry type to return (basin/county)", :query, false, String],
                "season"  => ["Season", :query, false, String],
              },
              tags: ["UMass", "Climate Data", "Public"]
    get "/umass/5yr/?" do
      cross_origin

      records = UMassClimateData5yr.get(params['area_type'], params['season'], params['variable_name'])

      #{"year":1950,
      # "observed": {
      #    01010002":60.837746,
      #    01010003":61.049713,
      #    01010004":61.655464,
      #    ....
      # },
      # "min45": ...,
      # "mean45": ...,
      # "max45": ...
      years = {}
      records.each do |rec|
        years[rec['year']] ||= {}
        years[rec['year']].tap do |res|
          res['year'] = rec['year']
          res['area_type'] = params['area_type']
          res['season'] = params['season'],
          res['variable_name'] = params['variable_name']

          # For each scenario - add.
          res["min"+rec['scenario']] ||= {}
          res["min"+rec['scenario']][rec['area_name']] = rec['min']

          res["med"+rec['scenario']] ||= {}
          res["med"+rec['scenario']][rec['area_name']] = rec['med']

          res["max"+rec['scenario']] ||= {}
          res["max"+rec['scenario']][rec['area_name']] = rec['max']
        end
      end

      json(years.map {|year, data| [year, data]})
    end
  end
end
