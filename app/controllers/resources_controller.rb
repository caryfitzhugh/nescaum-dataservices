require 'app/controllers/base'
module Controllers
  class ResourcesController < Controllers::Base
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

    type 'Facet', {
      properties: {
        value: {type: String, description: "Value for the facet"},
        count: {type: Integer, description: "Number of records that match with this facet"},
      }
    }

    type 'Facets', {
      properties: {
        actions:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        authors:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        climate_changes:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        effects:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        formats:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        geofocus:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        keywords:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        publishers:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        sectors:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        strategies:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
        states:  { type: ['Facet'], example: [{name: "ny", count: 3}, {name: "vt", checked: true,count: 55}]},
      }
    }

    type 'ResourceSearchResult', {
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
        uat: { type: Integer, example: Time.now.to_i, description: "Epoch timestamp when this document was indexed"},
      }
    }

    type 'SearchFilters', {
      properties: {
        actions:  { type: [String], example: ["Emissions Reduction", "Emissions Reduction::multiple emissions reduction actions"]},
        authors:  { type: [String], example: ["C.S. Lewis", "Northeast Regional Climate Center (NRCC)"]},
        climate_changes:  { type: [String], example: ["Precipitation", "Precipitation::Heavy Precipitation Events"]},
        effects: { type: [String], example: ["Specific Vulnerability", "Specific Vulnerability::Coastal Property Damage"]},
        formats: { type: [String], example: ["Documents", "Documents::Report"]},
        geofocus: { type: [String], example: ["Ulster County, NY", "Westchester County, NY", "Maine Coastland"]},
        keywords: { type: [String], example: ["dams", "floods", "land cover change"]},
        publishers: { type: [String], example: ["NOAA", "NESCAUM", "The Disney Corporation"]},
        sectors: { type: [String], example: ["Ecosystems", "Water Resources"]},
        states:    { type: [String], example: ["NY", "MA"]},
        strategies: { type: [String], example: ["Adaptation"]},
      }
    }

    type 'SearchRequestParameters', {
      properties: {
        page: { type: Integer, description: "Page of results being returned"},
        per_page: { type: Integer, description: "Number of results being returned"},
        query: {type: String, description: "The original search query"},
        published_on_end: {type: String, example: Date.today.to_s},
        published_on_start: {type: String, example: Date.today.to_s},
        filters: {type: "SearchFilters", description: "The filters used in this search"}
      }
    }

    type 'SearchResponse', {
      properties: {
        hits: { type: Integer, description: "Total number of records"},
        params: { type: 'SearchRequestParameters', description: "The incoming search parameters"},
        resources: { type: ["ResourceSearchResult"], description: "Results"},
        facets: { type: "Facets", description: "All the facets for searching"},
      }
    }

    endpoint description: "Search for resources",
              responses: standard_errors( 200 => "SearchResponse"),
              parameters: {
                "actions": ["Filter values AND, separate with a ,", :query, false, String],
                "authors": ["Filter values AND, separate with a ,", :query, false, String],
                "climate_changes": ["Filter values AND, separate with a ,", :query, false, String],
                "effects": ["Filter values AND, separate with a ,", :query, false, String],
                "formats": ["Filter values AND, separate with a ,", :query, false, String],
                "geofocus": ["Filter values AND, separate with a ,", :query, false, String],
                "keywords": ["Filter values AND, separate with a ,", :query, false, String],
                "publishers": ["Filter values AND, separate with a ,", :query, false, String],
                "sectors": ["Filter values AND, separate with a ,", :query, false, String],
                "strategies": ["Filter values AND, separate with a ,", :query, false, String],
                "states": ["Filter values AND, separate with a ,", :query, false, String],
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
      query = params[:query]
      filters = {}

      Cloudsearch::FILTERS.each do |filter|
        filters[filter] = params[filter].split(",") if params[filter]
      end

      result = Cloudsearch.search(query: query,
                                  filters: filters,
                                  page: page,
                                  per_page: per_page,
                                  pub_dates: [params[:published_on_start] ? Date.parse(params[:published_on_start]) : nil,
                                              params[:published_on_end] ? Date.parse(params[:published_on_end]) : nil])

      facets = result.facets.reduce({}) do |memo, (key, val)|
        memo[key] = val.buckets.map do |bucket|
          {value: bucket.value, count: bucket.count}
        end
        memo
      end

      json({
        hits: result.hits.found,
        params: {
          page: page,
          per_page: per_page,
          query: query,
          published_on_end: params[:published_on_end],
          published_on_start: params[:published_on_start],
          filters: filters,
        },
        resources: result.hits.hit.map do |hit|
          fields = hit["fields"]
          fields["uat"] = fields["uat"].flatten.first
          fields
        end,
        facets: facets,
      })
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
              responses: standard_errors( 200 => ["ResourceSearchResult"]),
              parameters: {
                "resource": ["Resource data", :body, true, "NewResource"],
              },
              tags: ["Resources", "Curator"]

    post "/resources/", require_role: :curator do
      doc = Models::Resource.new(params[:parsed_body][:resource])

      if doc.save
        Cloudsearch.add_documents([doc.to_search_document])
        json(doc.to_search_document(search_terms: false))
      else
        err(400, doc.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Update a resource",
              responses: standard_errors( 200 => ["ResourceSearchResult"]),
              parameters: {
                "resource": ["Resource data", :body, true, "NewResource"],
                "docid": ["Resource docid", :path, true, String],
              },
              tags: ["Resources", "Curator"]

    put "/resources/:docid", require_role: :curator do
      doc = Models::Resource.get_by_docid(params[:docid])
      doc.attributes = doc.attributes.merge(params[:parsed_body][:resource])

      if doc.save
        Cloudsearch.add_documents([doc.to_search_document])
        json(doc.to_search_document(search_terms: false))
      else
        err(400, doc.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Lookup a resource by docid",
              responses: standard_errors( 200 => ["ResourceSearchResult"]),
              parameters: {
                "docid": ["Doc id data", :path, true, String],
              },
              tags: ["Resources", "Public"]

    get "/resources/:docid" do
      doc = Models::Resource.get_by_docid(params[:docid])

      if doc
        json(doc.to_search_document(search_terms: false))
      else
        not_found("resource", params[:docid])
      end
    end
  end
end
