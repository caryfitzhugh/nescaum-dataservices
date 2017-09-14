require 'app/controllers/base'
require 'app/models'
module Controllers
  class FeedbackController < Controllers::Base
    type 'NewFeedback', {
      properties: {
        name: {type: String, description: "Name of the feedbacker"},
        organization: {type: String, description: "Name of the feedbacker's organization"},
        email: {type: String, description: "Email of the feedbacker"},
        phone: {type: String, description: "Phone of the feedbacker"},
        comment: {type: String, description: "Comment from the feedbacker"},
        contact: {type: 'boolean', description: "Should the feedbacker be contacted about this?"}
      }
    }

    type 'Feedback', {
      properties: {
        id: { type: Integer, description: "Collection ID"},
        name: {type: String, description: "Name of the feedbacker"},
        organization: {type: String, description: "Name of the feedbacker's organization"},
        email: {type: String, description: "Email of the feedbacker"},
        phone: {type: String, description: "Phone of the feedbacker"},
        comment: {type: String, description: "Comment from the feedbacker"},
        contact: {type: 'boolean', description: "Should the feedbacker be contacted about this?"}
      }
    }

    type 'FeedbackIndex', {
      properties: {
        total: {type: Integer},
        page: {type: Integer},
        per_page: {type: Integer},
        feedback: {type: ["Feedback"]}
      }
    }

    endpoint description: "Create Feedback",
              responses: standard_errors( 200 => ["Feedback"]),
              parameters: {
                "recaptcha": ["ReCaptcha Token", :body, true, String],
                "feedback": ["New Feedback", :body, true, "NewFeedback"],
              },
              tags: ["Collection"]

    post "/feedback" do
      cross_origin
      fb = Feedback.new(params[:parsed_body][:feedback])
      if fb.save
        json(fb.to_resource)
      else
        err(400, fb.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Index Feedback",
              responses: standard_errors( 200 => ["FeedbackIndex"]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Feedback", "Curator"]

    get "/feedback/?", require_role: :curator do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      fbs = Feedback.all(limit: per_page, offset: (per_page * (page  - 1)))

      json(
        total: Feedback.count,
        page: page,
        per_page: per_page,
        feedback: fbs.map(&:to_resource)
          )
    end

    endpoint description: "Get a feedback record",
              responses: standard_errors( 200 => ["Feedback"]),
              parameters: {
                "id": ["ID of the feedback to retrieve", :path, true, Integer],
              },
              tags: ["Collection", "Curator"]

    get "/feedback/:id", require_role: :curator do
      fb = Feedback.first(id: params[:id])

      if fb
        json(fb.to_resource)
      else
        not_found("Feedback", params[:id])
      end
    end


    endpoint description: "Delete a feedback",
              responses: standard_errors( 200 => ["Feedback"]),
              parameters: {
                "id": ["ID of the feedback to delete", :path, true, Integer],
              },
              tags: ["Collection", "Curator"]

    delete "/feedback/:id", require_role: :curator do
      fb = Feedback.first(id: params[:id])

      if fb
        if fb.destroy
          json(fb.to_resource)
        else
          err(400, fb.errors.full_messages.join("\n"))
        end
      else
        not_found("Feedback", params[:id])
      end
    end
  end
end
