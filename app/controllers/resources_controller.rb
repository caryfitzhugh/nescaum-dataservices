require 'app/controllers/base'
require 'app/controllers/geofocus_controller'
require 'app/models'

module Controllers
  class ResourcesController < Controllers::Base
    type 'Facet', {
      properties: {
        value: {type: String, description: "Value for the facet"},
        count: {type: Integer, description: "Number of records that match with this facet"},
      }
    }
    type 'FacetGroup', {
      properties: {
        name:   {type: String, description: "Name for the facet"},
        facets: {type: ["Facet"], description: "values for the facet"},
      }
    }

    type 'NewResource', {
      required: Resource::PROPERTIES.each_pair.map {|prop, attrs| if attrs[:required]
                                                                    prop
                                                                  else
                                                                    nil
                                                                  end}.compact,
      properties:
        Hash[Resource::PROPERTIES.each_pair.map do |name, attrs|
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
      end].merge(
        "geofocuses" => {type: [Integer], example: [1,2,3], description: "Geofocus ID to assign to this resource"}
      )

    }

    type 'Resource', {
      properties: Hash[Resource.properties.map do |prop|
          # Case statement didn't work?
          attrs = if prop.class == DataMapper::Property::Serial
            {type: Integer}
          elsif prop.class == DataMapper::Property::PgArray
            {type: [String]}
          elsif prop.class == DataMapper::Property::String
            {type: String}
          elsif prop.class == DataMapper::Property::Date
            {type: String, example: Date.today.to_s}
          elsif prop.class == DataMapper::Property::Boolean
            {type: 'boolean'}
          elsif prop.class == DataMapper::Property::DateTime
            {type: String, format: 'datetime', example: DateTime.now.to_s}
          else
            raise "ACK #{prop.class}"
          end
          [prop.name.to_s, attrs]
        end].merge("docid": {type: String},
                   image: {type: String, example: "http://s3.amazonaws.com/temp-bucket/img.png"},
                   geofocuses: {type: [Integer], example: [1,2,3]}
                 )
    }

    type 'Facets', {
      properties:
        Hash[Resource::FACETED_PROPERTIES.each_pair.map do |name, attrs|
            [name.to_s, {type: ['Facet'], example: [{ name: "f1", count: 1}, {name: "f2", count: 2}]}]
          end]
    }

    type 'SearchFilters', {
      properties:
        Hash[Resource::FACETED_PROPERTIES.each_pair.map do |name, attrs|
          [name.to_s, {type: [String], example: (attrs[:expanded] ? Resource.expand_literal(attrs[:example]) : attrs[:example]), description: attrs[:description]}]
        end]
    }

    type 'SearchRequestParameters', {
      properties: {
        query: {type: String, description: "The original search query"},
        geofocuses: {type: [Integer], description: "Geofocus to filter on"},
        bounding_box: {type: [Integer], description: "Array of lat/lng pairs to sort records by"},
        published_on_end: {type: String, example: Date.today.to_s},
        published_on_start: {type: String, example: Date.today.to_s},
        filters: {type: "SearchFilters", description: "The filters used in this search"}
      }
    }

    type 'SearchResponse', {
      properties: {
        total: { type: Integer, description: "Total number of records"},
        page: { type: Integer, description: "Page of results being returned"},
        per_page: { type: Integer, description: "Number of results being returned"},
        params: { type: 'SearchRequestParameters', description: "The incoming search parameters"},
        resources: { type: ["Resource"], description: "Results"},
        facets: { type: "Facets", description: "All the facets for searching"},
      }
    }

    type 'ResourceIndex', {
      properties: {
        total: {type: Integer},
        page: {type: Integer},
        per_page: {type: Integer},
        resources: {type: ["Resource"]}
      }
    }

    endpoint description: "Search for resources",
              responses: standard_errors( 200 => "SearchResponse"),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
                "bounding_box": ["Bounding box to search and sort results against '1 2, 2 3, 4 5, 5 6, 1 2'", :query, false, String],
                "published_on_end": ["Limit to resources publish dates to <= this publish end date", :query, false, String, :format => :date],
                "published_on_start": ["Limit to resources publish dates to >= this publish start date", :query, false, String, :format => :date],
                "geofocuses": ["Geofocuses to filter resources on, split by ','", :query, false, String]
              }.merge(
                Hash[Resource::FACETED_PROPERTIES.each_pair.map do |name, attrs|
                    [name.to_s, ["Filter. Separated by ,", :query, false, String]]
                  end]
              ),
              tags: ["Resources", "Public"]

    get "/resources" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      query = params[:query]
      geofocuses = (params[:geofocuses] || "").split(',').map(&:to_i)
      filters = {}

      Resource::FACETED_PROPERTIES.each do |name, attrs|
        filters[name] = params[name].split(",") if params[name]
      end

      bbox = nil
      if params[:bounding_box]
        bbox = params[:bounding_box].split(",").map {|pair| pair.split(" ").map(&:to_f)}
      end

      result = Resource.search(query: query,
                                  filters: filters,
                                  page: page,
                                  geofocuses: geofocuses,
                                  bounding_box: bbox,
                                  per_page: per_page,
                                  pub_dates: [params[:published_on_start] ? Date.parse(params[:published_on_start]) : nil,
                                              params[:published_on_end] ? Date.parse(params[:published_on_end]) : nil])
      facets = result.facets.reduce({}) do |memo, (key, val)|
        memo[key] = val.buckets.map do |bucket|
          {value: bucket.value, count: bucket.count}
        end
        memo
      end

      records = Resource.all_by_docids(result.hits.hit.map {|res| res.fields['docid'][0]}).map(&:to_resource)

      json({
        total: result.hits.found,
        page: page.to_i,
        per_page: per_page.to_i,
        resources: records,
        params: {
          query: query,
          geofocuses: geofocuses,
          published_on_end: params[:published_on_end],
          published_on_start: params[:published_on_start],
          filters: filters,
        },
        facets: facets,
      })
    end

    endpoint description: "List unindexed resources",
              responses: standard_errors( 200 => ["ResourceIndex"]),
              parameters: {
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Resources", "Curator"]

    get "/resources/unindexed", require_role: :curator do
      per_page = params[:per_page] || 50
      page = params[:page] || 1

      resources = Resource.all(:indexed => false, :order => [:created_at.desc], :limit => per_page, :offset => per_page * (page - 1))

      json(
        total: Resource.count,
        page: page,
        per_page: per_page,
        resources: resources.map(&:to_resource)
      )
    end

    endpoint description: "Search for all facets",
              responses: standard_errors( 200 => [["FacetGroup"]]),
              parameters: {
                "names": ["Name of the facet to get results for. split by ','", :path, true, String],
              },
              tags: ["Resources", "Public"]

    get "/resources/facets" do
      facets = params[:names].split(",").map(&:strip).reduce([]) do |memo, facet_name|
        memo.push({name: facet_name, facets: Cloudsearch.facet_list(facet_name).to_a})
        memo
      end
      json(facets)
    end

    endpoint description: "Create a resource",
              responses: standard_errors( 200 => ["Resource"]),
              parameters: {
                "resource": ["Resource data", :body, true, "NewResource"],
              },
              tags: ["Resources", "Curator"]

    post "/resources", require_role: :curator do
      doc = Resource.new(params[:parsed_body][:resource])
      doc.published_on_end ||= doc.published_on_start

      if doc.save
        Action.track!(doc, current_user, "Created")
        json(doc.to_resource)
      else
        err(400, doc.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Set a resource for indexing",
              responses: standard_errors( 200 => "Resource"),
              parameters: {
                "docid": ["Resource docid", :path, true, String],
              },
              tags: ["Resources", "Curator"]

    post "/resources/:docid/index", require_role: :curator do
      doc = Resource.get_by_docid(params[:docid])
      doc.indexed = true
      if doc.save
        doc.sync_index!
        Action.track!(doc, self.current_user, "Added to Index")
        json(doc.to_resource)
      else
        err(400, doc.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Remove a resource for indexing",
              responses: standard_errors( 200 => "Resource"),
              parameters: {
                "docid": ["Resource docid", :path, true, String],
              },
              tags: ["Resources", "Curator"]

    delete "/resources/:docid/index", require_role: :curator do
      doc = Resource.get_by_docid(params[:docid])
      doc.indexed = false
      if doc.save
        doc.sync_index!
        Action.track!(doc, current_user, "Removed from Index")
        json(doc.to_resource)
      else
        err(400, doc.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Update a resource",
              responses: standard_errors( 200 => "Resource"),
              parameters: {
                "resource": ["Resource data", :body, true, "NewResource"],
                "docid": ["Resource docid", :path, true, String],
              },
              tags: ["Resources", "Curator"]

    put "/resources/:docid", require_role: :curator do
      doc = Resource.get_by_docid(params[:docid])
      attrs = params[:parsed_body][:resource]
      attrs.delete('docid')
      doc.attributes = doc.attributes.merge(attrs)

      if doc.save
        doc.sync_index!
        Action.track!(doc, current_user, "Updated")
        json(doc.to_resource)
      else
        err(400, doc.errors.full_messages.join("\n"))
      end
    end

    endpoint description: "Delete a resource",
              responses: standard_errors( 200 => "Resource"),
              parameters: {
                "docid": ["Resource docid", :path, true, String],
              },
              tags: ["Resources", "Curator"]

    delete "/resources/:docid", require_role: :curator do
      doc = Resource.get_by_docid(params[:docid])

      if doc.destroy!
        Action.track!(doc, current_user, "Deleted")
        Cloudsearch.remove_documents([doc.docid])
        Action.track!(doc, current_user, "Removed from Index")
        json(doc.to_resource)
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
      doc = Resource.get_by_docid(params[:docid])

      if doc
        json(doc.to_resource)
      else
        not_found("resource", params[:docid])
      end
    end

  end
end
