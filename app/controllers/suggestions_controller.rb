require 'app/controllers/base'
require 'app/models'
module Controllers
  class SuggestionsController < Controllers::Base
    type 'NewSuggestion', {
      properties: {
        name: {type: String, description: "Name of the suggestioner"},
        email: {type: String, description: "Email of the suggestioner"},
        organization: {type: String, description: "Name of the suggestioner's organization"},
        phone: {type: String, description: "Phone of the suggestioner"},
        title: {type: String},
        description: {type: String},
        type: {type: String},
        href: {type: String, description: "Href of the suggested content"},
        source: {type: String},
        sectors: {type: [String]},
        keywords: {type: String},
      }
    }

    type 'Suggestion', {
      properties: {
        id: { type: Integer, description: "Collection ID"},
        name: {type: String, description: "Name of the suggestioner"},
        email: {type: String, description: "Email of the suggestioner"},
        organization: {type: String, description: "Name of the suggestioner's organization"},
        phone: {type: String, description: "Phone of the suggestioner"},
        title: {type: String},
        description: {type: String},
        type: {type: String},
        href: {type: String, description: "Href of the suggested content"},
        source: {type: String},
        sectors: {type: [String]},
        keywords: {type: String},
      }
    }

    type 'SuggestionIndex', {
      properties: {
        total: {type: Integer},
        page: {type: Integer},
        per_page: {type: Integer},
        suggestions: {type: ["Suggestion"]}
      }
    }

    endpoint description: "Create Suggestion",
              responses: standard_errors( 200 => ["Suggestion"]),
              parameters: {
                "suggestion": ["New Suggestion", :body, true, "NewSuggestion"],
              },
              tags: ["Collection"]

    post "/suggestion" do
      cross_origin
      fb = Suggestion.new(params[:parsed_body][:suggestion])
      if fb.save
        json(fb.to_resource)
      else
        err(400, fb.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Index Suggestion",
              responses: standard_errors( 200 => ["SuggestionIndex"]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Suggestion", "Curator"]

    get "/suggestion/?", require_role: :curator do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      fbs = Suggestion.all(limit: per_page, offset: (per_page * (page  - 1)))

      json(
        total: Suggestion.count,
        page: page,
        per_page: per_page,
        suggestions: fbs.map(&:to_resource)
          )
    end

    endpoint description: "Get a suggestion record",
              responses: standard_errors( 200 => ["Suggestion"]),
              parameters: {
                "id": ["ID of the suggestion to retrieve", :path, true, Integer],
              },
              tags: ["Collection", "Curator"]

    get "/suggestion/:id", require_role: :curator do
      fb = Suggestion.first(id: params[:id])

      if fb
        json(fb.to_resource)
      else
        not_found("Suggestion", params[:id])
      end
    end


    endpoint description: "Delete a suggestion",
              responses: standard_errors( 200 => ["Suggestion"]),
              parameters: {
                "id": ["ID of the suggestion to delete", :path, true, Integer],
              },
              tags: ["Collection", "Curator"]

    delete "/suggestions/:id", require_role: :curator do
      fb = Suggestion.first(id: params[:id])

      if fb
        if fb.destroy
          json(fb.to_resource)
        else
          err(400, fb.errors.full_messages.join("\n"))
        end
      else
        not_found("Suggestion", params[:id])
      end
    end
  end
end
