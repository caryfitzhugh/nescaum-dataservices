require 'app/controllers/base'
require 'app/models'

module Controllers
  class ActionsController < Controllers::Base
    type 'ActionEvent', {
      properties: {
        id: { type: Integer, description: "Event ID"},
        user_id: { type: Integer, description: "User ID"},
        type: {type: String, description: "record type"},
        record_id: { type: Integer, description: "The id of the record that was changed"},
        message: {type: String, description: "What occurred"},
        at: { type: String, format: "date-time", description: "When it happened"},
        identifier: { type: String, description: "Human-readable identifier"}
      }
    }

    type 'ActionIndex', {
      properties: {
        total: {type: Integer},
        page: {type: Integer},
        per_page: {type: Integer},
        actions: {type: ["ActionEvent"]}
      }
    }

    endpoint description: "Get Actions",
              responses: standard_errors( 200 => ["ActionIndex"]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
                "user_id": ["Scope to particular user", :query, false, Integer, :minimum => 0],
                "end": ["Limit to action at dates to <= this end date", :query, false, String, :format => :datetime],
                "start": ["Limit to action at dates to >= this start date", :query, false, String, :format => :datetime],
              },
              tags: ["Action", "Curator"]

    get "/actions/?", require_role: :curator do
      per_page = params[:per_page] || 50
      page = params[:page] || 1

      actions = if params[:user_id]
                  Action.all(user_id: params[:user_id])
                else
                  Action.all
                end

      if params[:start]
        actions = actions.all(:at.gte => DateTime.parse(params[:start]))
      end

      if params[:end]
        actions = actions.all(:at.lte => DateTime.parse(params[:end]))
      end

      actions = actions.all(:order  => [:at.desc])

      json(
        total: actions.count,
        page: page,
        per_page: per_page,
        actions: actions.all(offset: (per_page * (page - 1)), limit: (per_page)).map(&:to_resource))
    end
  end
end
