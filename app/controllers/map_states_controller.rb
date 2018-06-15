require 'app/controllers/base'
require 'app/models'
module Controllers
  class MapStatesController < Controllers::Base
    type 'MapState', {
      properties: {
        data: {type: String, description: "the JSON string"},
      }
    }
    type 'MapStateToken', {
      properties: {
        token: {type: String, description: "the MD5 token for the map data"},
      }
    }

    endpoint description: "Save Map State",
              responses: standard_errors( 200 => ["MapStateToken"]),
              parameters: {
                "map_state": ["MapState", :body, true, String],
              },
              tags: ["Mapping"]

    post "/map_states/?" do
      cross_origin
      map_state_data = params[:parsed_body][:map_state]
      map_state = MapState.new()
      map_state.data = map_state_data
      map_state.generate_token!

      if map_state.save
        json({"token" => map_state.token})
      else
        err(400, map_state.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Get Map State",
              responses: standard_errors( 200 => ["MapState"]),
              parameters: {
                "token": ["Token of map state to return", :query, true, String],
              },
              tags: ["Mapping"]

    get "/map_states/:token" do
      cross_origin
      map_state = MapState.first(token: params[:token])

      if map_state
        json(map_state.to_resource)
      else
        not_found("MapState", params[:token])
      end
    end
  end
end
