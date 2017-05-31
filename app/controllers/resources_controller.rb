require 'app/controllers/base'
module Controllers
  class ResourcesController < Controllers::Base
    type 'Facet', {
      required: [:name, :count],
      properties: {
        name: { type: String },
        count: {type: Integer },
      }
    }
    type 'NewResource', {
      properties: {
        actions:  { type: [String], example: ["Emissions Reduction::multiple emissions reduction actions"]},
        authors:  { type: [String], example: ["C.S. Lewis", "Northeast Regional Climate Center (NRCC)"]},
        climate_changes:  { type: [String], example: ["Precipitation::Heavy Precipitation Events"]},
        content: { type: String, example: "Markdown content describing the resource"},
        effects: { type: [String], example: ["Specific Vulnerability", "Specific Vulnerability::Coastal Property Damage"]},
        format: { type: String, example: "Documents::Report"},
        geofocus: { type: [String], example: ["Ulster County, NY", "Westchester County, NY", "Maine Coastland"]},
        keywords: { type: [String], example: ["dams", "floods", "land cover change"]},
        external_data_links:  { type: [String], example: ["pdf::http://123.com/pdf", "weblink::http://123.com/abc.html"]},
        published_on_end: {type:Date, example: Date.today.to_s},
        published_on_start: {type: Date, example: Date.today.to_s, description:"The start of the publcation window (i.e. if it's a single day, start/end are equal. If it's a fuzzier range such as 'Oct 2014', the start is Oct 1, 2014 and the end is Oct 31, 2014"},
        publishers: { type: [String], example: ["NOAA", "NESCAUM", "The Disney Corporation"]},
        sectors: { type: [String], example: ["Ecosystems", "Water Resources"]},
        states:    { type: [String], example: ["NY", "MA"]},
        strategies: { type: [String], example: ["Adaptation"]},
        title: { type: String, example: "Title of the resource"},
        subtitle: {type: String, example: "Sub-title"},
      }
    }

    type 'SearchResourceResult', {
      required: [:title, :docid],
      properties: {
        actions:  { type: [String], example: ["Emissions Reduction", "Emissions Reduction::multiple emissions reduction actions"]},
        authors:  { type: [String], example: ["C.S. Lewis", "Northeast Regional Climate Center (NRCC)"]},
        climate_changes:  { type: [String], example: ["Precipitation", "Precipitation::Heavy Precipitation Events"]},
        content: { type: String, example: "Markdown content describing the resource"},
        docid:  { type: String, example: "maps::44"},
        effects: { type: [String], example: ["Specific Vulnerability", "Specific Vulnerability::Coastal Property Damage"]},
        formats: { type: [String], example: ["Documents", "Documents::Report"]},
        geofocus: { type: [String], example: ["Ulster County, NY", "Westchester County, NY", "Maine Coastland"]},
        keywords: { type: [String], example: ["dams", "floods", "land cover change"]},
        external_data_links:  { type: [String], example: ["pdf::http://123.com/pdf", "weblink::http://123.com/abc.html"]},
        published_on_end: {type:Date, example: Date.today.to_s},
        published_on_start: {type: Date, example: Date.today.to_s, description:"The start of the publcation window (i.e. if it's a single day, start/end are equal. If it's a fuzzier range such as 'Oct 2014', the start is Oct 1, 2014 and the end is Oct 31, 2014"},
        publishers: { type: [String], example: ["NOAA", "NESCAUM", "The Disney Corporation"]},
        sectors: { type: [String], example: ["Ecosystems", "Water Resources"]},
        states:    { type: [String], example: ["NY", "MA"]},
        strategies: { type: [String], example: ["Adaptation"]},
        title: { type: String, example: "To be determined, the data abstracts needed for a search result page"},
        subtitle: {type: String, example: "Sub-title example"},
      }
    }

    type 'QueryFacet', {
      properties: {
        name:  { type: String, example: "actions"},
        values:  { type: [String], example: ["run", "hide"]},
      }
    }

    endpoint description: "Search for resources",
              responses: standard_errors( 200 => [["SearchResourceResult"]]),
              parameters: {
                "actions": ["Facet values AND, separate with a ,", :query, false, String],
                "authors": ["Facet values AND, separate with a ,", :query, false, String],
                "climate_changes": ["Facet values AND, separate with a ,", :query, false, String],
                "effects": ["Facet values AND, separate with a ,", :query, false, String],
                "formats": ["Facet values AND, separate with a ,", :query, false, String],
                "geofocus": ["Facet values AND, separate with a ,", :query, false, String],
                "keywords": ["Facet values AND, separate with a ,", :query, false, String],
                "publishers": ["Facet values AND, separate with a ,", :query, false, String],
                "sectors": ["Facet values AND, separate with a ,", :query, false, String],
                "strategies": ["Facet values AND, separate with a ,", :query, false, String],
                "states": ["Facet values AND, separate with a ,", :query, false, String],
                "query": ["Query string to search for", :query, false, String],
                "published_on_end": ["Limit to resources publish dates to <= this publish end date", :query, false, String, :format => :date],
                "published_on_start": ["Limit to resources publish dates to >= this publish start date", :query, false, String, :format => :date],
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Resources", "Public"]

    get "/resources" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      facets = {}

      [:actions, :authors, :climate_changes, :effects, :formats, :geofocus, :keywords, :publishers, :sectors, :strategies, :states].each do |facet|
        facets[facet] = params[facet].split(",") if params[facet]
      end

      resources = Cloudsearch.search(query: params[:query],
                                     facets: facets,
                                     page: page,
                                     per_page: per_page,
                                     pub_dates: [params[:published_on_start] ? Date.parse(params[:published_on_start]) : nil,
                                                 params[:published_on_end] ? Date.parse(params[:published_on_end]) : nil])
      json(resources.to_a)
    end

    endpoint description: "Search for all facets",
              responses: standard_errors( 200 => [["Facet"]]),
              parameters: {
                "name": ["Name of the facet to get results for", :path, true, String],
              },
              tags: ["Resources", "Public"]

    get "/resources/facets/:name" do
      facets = Cloudsearch.facet_list(params[:name])
      json(facets.to_a)
    end

    endpoint description: "Create a resource",
              responses: standard_errors( 200 => ["Resource"]),
              parameters: {
                "resource": ["Resource data", :body, true, "NewResource"],
              },
              tags: ["Resources", "Curator"]

    post "/resources/", require_role: :curator do
      doc = Models::Resource.new(params[:parsed_body][:resource])
      if doc.save
        json(
require 'pry'; binding.pry
      json([])
    end
  end
end
