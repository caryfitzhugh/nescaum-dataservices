require 'app/controllers/base'
require 'app/models'

module Controllers
  class ResourcesController < Controllers::Base
    type 'Resources', {
      required: [:name, :document_url],
      properties: {
        id: {type: Integer, example: "1"},
        name: { type: String, example: "Document determining temperature change ..."},
        document_url: { type: String, example: "http://s3.document.com"},
      }
    }

    endpoint description: "Lookup and manage resources",
              responses: { 200 => [["Resources"]]},
              tags: "Resources"

    get Paths.resources_path do
      resources = Models::Resource.find()
      json(resources)
    end
  end
end
