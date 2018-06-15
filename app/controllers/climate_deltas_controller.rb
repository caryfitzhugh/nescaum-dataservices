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

    type 'ClimateDataDetailsData', {
      properties: {
        high: { type: Float, description: "Range High" },
        low: { type: Float, description: "Range Low"},
        baseline: { type: Float, description: "Baseline"},
        average: { type: Float, description: "The data average"},
      }
    }
    type 'ClimateDataDetails', {
      properties: {
        state: { type: String, description: "State of data"},
        county: { type: String, description: "County for data"},
        uid: { type: String, description: "UID of data location"},
        year:   { type: Integer, description: "Year of data:  " + [2030, 2050, 2070, 2090].to_json},
        variable: { type: String, description: "Variable of data: " + [
                           'tempgt95',
                           'precipgt4',
                           'heatdegdays',
                           'templt0',
                           'tempgt90',
                           'maxtemp',
                           'cooldegdays',
                           'avgtemp',
                           'templt32',
                           'mintemp',
                           'precipgt1',
                           'tempgt100',
                           'consdrydays',
                           'growdegdays',
                           'precipgt2',
                           'precip'].to_json},
        season: { type: String, description: "Seasons for data: " + ['spring', 'summer', 'fall', 'winter', 'annual'].to_json},
        data: { type: 'ClimateDataDetailsData', description: "The Data"}
      }
    }

    endpoint description: "Get Climate Data",
              responses: standard_errors( 200 => "ClimateDeltaGeoJSON"),
              parameters: {
                "variables"  => ["Variables to return data on, comma sep", :query, false, String],
                "seasons"  => ["Seasons to return data on, comma sep", :query, false, String],
                "years"  => ["Years name to return data on, comma sep", :query, false, String],
                "counties"  => ["County name to return data on, comma sep", :query, false, String],
                "states"  => ["County name to return data on, comma sep", :query, false, String],
                "uids"  => ["UIDs name to return data on, comma sep", :query, false, String],
              },
              tags: ["Climate Data", "Public"]

    get "/climate-data/details/?" do
      cross_origin
        #   :state/:county/:year/:variable/:season/?" do
      states = (params['states'].split(",").map(&:strip)) rescue []
      counties = (params['counties'].split(",").map(&:strip)) rescue []
      years = (params['years'].split(",").map(&:strip).map(&:to_i)) rescue []
      seasons = (params['seasons'].split(",").map(&:strip)) rescue []
      variables = (params['variables'].split(",").map(&:strip)) rescue []
      uids = (params['uids'].split(",").map(&:strip)) rescue []

      json(ClimateData.climate_delta_details(states: states,
                                             counties: counties,
                                             uids: uids,
                                             years: years,
                                             seasons: seasons,
                                             variables: variables))
    end
  end
end
