require 'app/controllers/base'
require 'app/models'
module Controllers
  class ResourcesController < Controllers::Base
    type 'Facet', {
      properties: {
        value: {type: String, description: "Value for the facet"},
        count: {type: Integer, description: "Number of records that match with this facet"},
      }
    }

    type 'NewResource', {
      properties:
        Hash[Models::Resource::PROPERTIES.each_pair.map do |name, attrs|
          if attrs[:facet]
            [name.to_s, {type: [String], example: attrs[:example], description: attrs[:description]}]
          elsif attrs[:type] == String
            [name.to_s, {type: String, example: attrs[:example], description: attrs[:description]}]
          elsif attrs[:type] == Date
            [name.to_s, {type: Date, example: attrs[:example], description: attrs[:description]}]
          elsif attrs[:type] == DataMapper::Property::PgArray
            [name.to_s, {type: [String], example: attrs[:example], description: attrs[:description]}]
          else
            throw "How to convert: #{name}"
          end
        end]
    }

    type 'Resource', {
      properties: Hash[Models::Resource.properties.map do |prop|
          # Case statement didn't work?
          klass = if prop.class == DataMapper::Property::Serial
            Integer
          elsif prop.class == DataMapper::Property::PgArray
            [String]
          elsif prop.class == DataMapper::Property::String
            String
          elsif prop.class == DataMapper::Property::Date
            Date
          elsif prop.class == DataMapper::Property::Boolean
            'boolean'
          else
            raise "ACK #{prop.class}"
          end
          [prop.name.to_s, {type: klass}]
        end].merge("docid": {type: String})
    }

    type 'Facets', {
      properties:
        Hash[Models::Resource::FACETED_PROPERTIES.each_pair.map do |name, attrs|
            [name.to_s, {type: ['Facet'], example: [{ name: "f1", count: 1}, {name: "f2", count: 2}]}]
          end]
    }

    type 'ResourceSearchResult', {
      required: [:title, :docid],
      properties:{
        docid:  { type: String, example: "maps::44"},
      }.merge(
        Hash[Models::Resource::PROPERTIES.each_pair.map do |name, attrs|
          if attrs[:facet]
            [name.to_s, {type: [String], example: (attrs[:expanded] ? Models::Resource.expand_literal(attrs[:example]) : attrs[:example]), description: attrs[:description]}]
          elsif attrs[:type] == String
            [name.to_s, {type: String, example: attrs[:example], description: attrs[:description]}]
          elsif attrs[:type] == Date
            [name.to_s, {type: Date, example: attrs[:example], description: attrs[:description]}]
          elsif attrs[:type] == DataMapper::Property::PgArray
            [name.to_s, {type: [String], example: attrs[:example], description: attrs[:description]}]
          else
            throw "How to convert: #{name}"
          end
        end])
    }

    type 'SearchFilters', {
      properties:
        Hash[Models::Resource::FACETED_PROPERTIES.each_pair.map do |name, attrs|
          [name.to_s, {type: [String], example: (attrs[:expanded] ? Models::Resource.expand_literal(attrs[:example]) : attrs[:example]), description: attrs[:description]}]
        end]
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
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
                "published_on_end": ["Limit to resources publish dates to <= this publish end date", :query, false, String, :format => :date],
                "published_on_start": ["Limit to resources publish dates to >= this publish start date", :query, false, String, :format => :date],
              }.merge(
                Hash[Models::Resource::FACETED_PROPERTIES.each_pair.map do |name, attrs|
                    [name.to_s, ["Filter. Separated by ,", :query, false, String]]
                  end]
              ),
              tags: ["Resources", "Public"]

    get "/resources" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      query = params[:query]
      filters = {}

      Models::Resource::FACETED_PROPERTIES.each do |name, attrs|
        filters[name] = params[name].split(",") if params[name]
      end

      result = Models::Resource.search(query: query,
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
              responses: standard_errors( 200 => "Resource"),
              parameters: {
                "docid": ["Doc id data", :path, true, String],
              },
              tags: ["Resources", "Public"]

    get "/resources/:docid" do
      doc = Models::Resource.get_by_docid(params[:docid])

      if doc
        json(doc.attributes.merge(docid: doc.docid))
      else
        not_found("resource", params[:docid])
      end
    end
  end
end
