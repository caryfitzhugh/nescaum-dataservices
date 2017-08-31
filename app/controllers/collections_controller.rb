require 'app/controllers/base'
require 'app/controllers/resources_controller'
require 'app/models'
module Controllers
  class CollectionsController < Controllers::Base
    type 'NewCollection', {
      properties: {
        name: {type: String, description: "Name of the collection"},
        resources: {type: [String], description: "Docids of the collection"}
      }
    }

    type 'Collection', {
      properties: {
        id: { type: Integer, description: "Collection ID"},
        name: {type: String, description: "Name of the collection"},
        resources: {type: ['Resource'], description: "Resources of the collection"}
      }
    }

    type 'CollectionIndex', {
      properties: {
        total: {type: Integer},
        page: {type: Integer},
        per_page: {type: Integer},
        collections: {type: ["Collection"]}
      }
    }

    endpoint description: "Create Collection",
              responses: standard_errors( 200 => ["Collection"]),
              parameters: {
                "collection": ["New Collection", :body, true, "NewCollection"],
              },
              tags: ["Collection", "Curator"]

    post "/collections", require_role: :curator do
      collection = Collection.new(params[:parsed_body][:collection])
      if collection.save
        Action.track!(collection, current_user, "Created")
        json(collection.to_resource)
      else
        err(400, collection.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Index Collection",
              responses: standard_errors( 200 => ["CollectionIndex"]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Collection", "Public"]

    get "/collections/?" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      collections = Collection.all(limit: per_page, offset: (per_page * (page  - 1)))

      json(
        total: Collection.count,
        page: page,
        per_page: per_page,
        collections: collections.map(&:to_resource)
          )
    end

    endpoint description: "Get a collection by name",
              responses: standard_errors( 200 => ["Collection"]),
              parameters: {
                "name": ["name of the collection to retrieve", :path, true, String],
              },
              tags: ["Collection", "Public"]

    get "/collections/by-name/*" do
      collection = Collection.first(name: params[:splat])

      if collection
        json(collection.to_resource)
      else
        not_found("Collection", params[:splat])
      end
    end

    endpoint description: "Get a collection",
              responses: standard_errors( 200 => ["Collection"]),
              parameters: {
                "id": ["ID of the collection to retrieve", :path, true, Integer],
              },
              tags: ["Collection", "Public"]

    get "/collections/:id" do
      collection = Collection.first(id: params[:id])

      if collection
        json(collection.to_resource)
      else
        not_found("Collection", params[:id])
      end
    end


    endpoint description: "Delete a collection",
              responses: standard_errors( 200 => ["Collection"]),
              parameters: {
                "id": ["ID of the collection to delete", :path, true, Integer],
              },
              tags: ["Collection", "Curator"]

    delete "/collections/:id", require_role: :curator do
      collection = Collection.first(id: params[:id])

      if collection
        if collection.destroy
          Action.track!(collection, current_user, "Deleted")
          json(collection.to_resource)
        else
          err(400, collection.errors.full_messages.join("\n"))
        end
      else
        not_found("Collection", params[:id])
      end
    end

    endpoint description: "Update a collection",
              responses: standard_errors( 200 => ["Collection"]),
              parameters: {
                "id": ["ID of the collection to update", :path, true, Integer],
                "collection": ["New Collection", :body, true, "NewCollection"],
              },
              tags: ["Collection", "Curator"]

    put "/collections/:id", require_role: :curator do
      collection = Collection.first(id: params[:id])
      if collection
        if collection.update(params[:parsed_body][:collection])
          Action.track!(collection, current_user, "Updated")
          json(collection.to_resource)
        else
          err(400, collection.errors.full_messages.join("\n"))
        end
      else
        not_found("Collection", params[:id])
      end
    end
  end
end
