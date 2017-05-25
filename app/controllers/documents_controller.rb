require 'app/controllers/base'
require 'app/models/document'
module Controllers
  class DocumentsController < Controllers::Base
    type 'DocumentNew', {
      required: [:title, :type, :sector_id],
      properties: {
        title: { type: String, example: "Document determining temperature change ..."},
        type: { type: String, example: "Article"},
        sector_id: { type: Integer, example: "42"},
      }
    }
    type 'DocumentTypes', {
      required: [:types],
      properties: {
        types: { type: [String], example: ["Article"]},
      }
    }

    type 'Document', {
      required: [:title],
      properties: {
        id: {type: Integer, example: "1"},
        title: { type: String, example: "Document determining temperature change ..."},
        sector_id: { type: Integer, example: "42"},
      }
    }

    endpoint description: "Lookup and manage Documents",
              responses: standard_errors( 200 => [["Document"]]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Documents", "Public"]

    get "/documents" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      resources = Models::Document.all(offset: page - 1, limit: per_page)
      json(resources.to_a)
    end

   endpoint description: "Lookup all current document types",
             responses: standard_errors( 200 => ['DocumentTypes']),
             parameters: {},
             tags: ["Documents", "Public"]

    get "/documents/types" do
      doc_types = Models::Document.all_types
      json({types: doc_types})
    end

    endpoint description: "Create document",
              parameters: {
                "document": ["Document to create", :body, true, "DocumentNew"]
              },
              responses: standard_errors( 200 => ["Document"]),
              tags: ["Documents", "Curation"]

    post "/documents", require_role: :curator do
      document = Models::Document.new(params[:parsed_body][:document])

      if document.save
        json(document)
      else
        err(400, document.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Delete documents",
              parameters: {
                "id": ["Document to delete", :path, true, Integer]
              },
              responses: standard_errors( 200 => ["Document"]),
              tags: ["Documents", "Curation"]

    delete "/documents/:id", require_role: :curator do
      document = Models::Document.get(params[:id])
      if document.nil?
        not_found("Document", params[:id])
      elsif document.destroy
        json(document)
      else
        err(400, document.errors.full_messages.join("\n"))
      end
    end
  end
end
