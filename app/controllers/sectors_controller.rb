module Controllers
  class SectorsController < Controllers::Base
    type 'SectorNew', {
      required: [:name],
      properties: {
        name: { type: String, example: "Infrastructure"},
      }
    }

    type 'Sector', {
      required: [:id, :name],
      properties: {
        id: {type: Integer, example: "1"},
        name: { type: String, example: "Infrastructure"},
      }
    }

    endpoint description: "Lookup sectors",
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
                "name": ["Search by name", :query, false, String],
              },
              responses: standard_errors( 200 => [["Sector"]]),
              tags: ["Sectors", "Public"]
    get "/sectors" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      sectors = Models::Sector.all(offset: page - 1, limit: per_page)
      if params[:name]
        sectors = sectors.all(:name.like => "%#{params[:name]}%")
      end
      json(sectors.to_a)
    end

    endpoint description: "Create sectors",
              parameters: {
                "sector": ["Sector to create", :body, true, "SectorNew"]
              },
              responses: standard_errors( 200 => ["Sector"]),
              tags: ["Sectors", "Curation"]
    post "/sectors", require_role: :curator do
      sector = Models::Sector.new(params[:parsed_body][:sector])

      if sector.save
        json(sector)
      else
        err(400, sector.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Delete sectors",
              parameters: {
                "id": ["Sector to delete", :path, true, Integer]
              },
              responses: standard_errors( 200 => ["Sector"]),
              tags: ["Sectors", "Curation"]

    delete "/sectors/:id", require_role: :curator do
      sector = Models::Sector.get(params[:id])
      if sector.nil?
        not_found("Sector", params[:id])
      elsif sector.destroy
        json(sector)
      else
        err(400, sector.errors.full_messages.join("\n"))
      end
    end
  end
end
