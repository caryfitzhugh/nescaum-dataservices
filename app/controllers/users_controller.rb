require 'app/controllers/base'
require 'app/models'
module Controllers
  class UsersController < Controllers::Base
    type 'User', {
      properties: {
        id: { type: Integer, description: "User ID"},
        name: {type: String, description: "User name"},
      }
    }

    type 'UsersIndex', {
      properties: {
        total: {type: Integer},
        page: {type: Integer},
        per_page: {type: Integer},
        users: {type: ["User"]}
      }
    }

    endpoint description: "Get a user",
              responses: standard_errors( 200 => ["User"]),
              parameters: {
                "id": ["ID of the User to retrieve", :path, true, Integer],
              },
              tags: ["User", "Public"]

    get "/users/:id" do
      user = User.first(id: params[:id])

      if user
        json(user.to_resource)
      else
        not_found("User", params[:id])
      end
    end

    endpoint description: "Get all users",
              responses: standard_errors( 200 => ["UsersIndex"]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["User", "Public"]

    get "/users" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1

      users = User.all(offset: (per_page * (page - 1)), limit: per_page)

      json(
        total: User.count,
        page: page,
        per_page: per_page,
        users: users.map(&:to_resource))
    end
  end
end
