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
      required: [
      ],
      properties: {
        :title => {type: String, example: "Title of the resource"},
        :subtitle => {type: String, example: "Subtitle"},
        :image => {type: String, example: "http://lorempixel.com/500/500"},
        :content => {type: String, example: "Markdown **so** awesome", description: "The abstract"},
        :external_data_links => {type: [String], example: ["pdf::http://www.com/pdf", "weblink::http://google.com"]},
        :published_on_start => {type: String, example: "2017-01-31"},
        :published_on_end => {type: String, example: "2017-01-31"},
        :geofocuses => {type: [Integer], example: [1,2,3], description: "Geofocus ID to assign to this resource"},
        :actions => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :authors => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :climate_changes => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :content_types => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :keywords => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :publishers => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :sectors => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :strategies => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :states => {type: [String], example: ["MA::facet", "NY::facet like this"]},
      }
    }

    type 'Resource', {
      properties: {
        :docid => {type: String},
        :indexed => {type: 'boolean', example: "Is this resource in the public index?"},
        :title => {type: String, example: "Title of the resource"},
        :subtitle => {type: String, example: "Subtitle"},
        :image => {type: String, example: "http://lorempixel.com/500/500"},
        :content => {type: String, example: "Markdown **so** awesome", description: "The abstract"},
        :external_data_links => {type: [String], example: ["pdf::http://www.com/pdf", "weblink::http://google.com"]},
        :published_on_start => {type: String, example: "2017-01-31"},
        :published_on_end => {type: String, example: "2017-01-31"},
        :geofocuses => {type: [Integer], example: [1,2,3], description: "Geofocus ID to assign to this resource"},
        :actions => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :authors => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :climate_changes => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :content_types => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :keywords => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :publishers => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :sectors => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :strategies => {type: [String], example: ["MA::facet", "NY::facet like this"]},
        :states => {type: [String], example: ["MA::facet", "NY::facet like this"]},
      }
    }

    type 'Facets', {
      properties:
        Hash[Resource::FACETED_PROPERTIES.each.map do |name|
            [name.to_s, {type: ['Facet'], example: [{ name: "f1", count: 1}, {name: "f2", count: 2}]}]
          end]
    }

    type 'SearchFilters', {
      properties:
        Hash[Resource::FACETED_PROPERTIES.each.map do |name|
          [name.to_s, {type: [String]}]
        end]
    }

    type 'SearchRequestParameters', {
      properties: {
        query: {type: String, description: "The original search query"},
        geofocuses: {type: [Integer], description: "Geofocus to filter on"},
        bounding_box: {type: [Integer], description: "SW, NE list of lng, lat pairs, separated by , (leaflet.toBBoxString())", example: "23.7,90.2,23.9,90.7"},
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
                "bounding_box": ["SW, NE list of lng, lat pairs, separated by , (leaflet.toBBoxString())", :query, false, String],
                "published_on_end": ["Limit to resources publish dates to <= this publish end date", :query, false, String, :format => :date],
                "published_on_start": ["Limit to resources publish dates to >= this publish start date", :query, false, String, :format => :date],
                "geofocuses": ["Geofocuses to filter resources on, split by ','", :query, false, String]
              }.merge(
                Hash[Resource::FACETED_PROPERTIES.each.map do |name|
                    [name.to_s, ["Filter. Separated by ,", :query, false, String]]
                  end]
              ),
              tags: ["Resources", "Public"]

    get "/resources/?" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      query = params[:query]
      geofocuses = (params[:geofocuses] || "").split(',').map(&:to_i)
      filters = {}

      Resource::FACETED_PROPERTIES.each do |name|
        filters[name] = params[name].split(",") if params[name]
      end

      bbox = nil
      if params[:bounding_box]
        bbox = params[:bounding_box].split(",").map(&:to_f)
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
      p = params[:parsed_body][:resource]
      p[:published_on_end] = p[:published_on_end] || p[:published_on_start]

      doc = Resource.new
      update_resource(doc, p)

      if doc.save
        doc.reload
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
      update_resource(doc,attrs)

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

      if doc.destroy
        Action.track!(doc, current_user, "Deleted")
        Cloudsearch.remove_documents([doc.docid])
        Action.track!(doc, current_user, "Removed from Index")
        json(doc.to_resource)
      else
        err(400, doc.errors.full_messages.join("\n"))
      end
    end


    type 'FieldResponse', {
      properties: {
        total: { type: Integer, description: "Total number of records"},
        page: { type: Integer, description: "Page of results being returned"},
        per_page: { type: Integer, description: "Number of results being returned"},
        values: {type: [String], description: "Value for the facet"},
      }
    }
    endpoint description: "Find data on a field",
              responses: standard_errors( 200 => "FieldResponse"),
              parameters: {
                "field_name": ["Field name to search", :query, true, String],
                "query": ["Field name query to use", :query, false, String],
                "page": ["Page of records to return", :query, false, Integer, :minimum => 1],
                "per_page": ["Number of records to return", :query, false, Integer, {:minimum => 1, :maximum => 100}],
              },
              tags: ["Resources", "Public"]


    get "/resources/fields" do
      per_page = params[:per_page] || 50
      page = params[:page] || 1
      all = case params[:field_name].downcase.to_sym
              when :actions
                ResourceAction.all
              when :authors
                ResourceAuthor.all
              when :climate_changes
                ResourceClimateChange.all
              when :content_types
                ResourceContentType.all
              when :effects
                ResourceEffect.all
              when :keywords
                ResourceKeyword.all
              when :publishers
                ResourcePublisher.all
              when :sectors
                ResourceSector.all
              when :strategies
                ResourceStrategy.all
              when :states
                ResourceState.all
              end.all(:value.ilike => "%#{params[:query]}%")

      json(
        total: all.count,
        page: page,
        per_page: per_page,
        values: all.all(:order => [:value.asc],
                           :limit => per_page, :offset => per_page * (page - 1)).map(&:value)
      )

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

    private

    def update_resource(doc, p)
      doc.title = p[:title] if p[:title]
      doc.subtitle = p[:subtitle] if p[:subtitle]
      doc.image = p[:image] if p[:image]
      doc.content = p[:content] if p[:content]
      doc.external_data_links = p[:external_data_links]  if p[:external_data_links]
      doc.geofocuses = p[:geofocuses] if p[:geofocuses]
      doc.published_on_start = p[:published_on_start] if p[:published_on_start]
      doc.published_on_end = p[:published_on_end] || doc.published_on_start
      doc.resource_content_types  = (p[:content_types] || []).map { |v| ResourceContentType.first_or_create(value: v) } if p[:content_types]
      doc.resource_actions = (p[:actions] || []).map { |v| ResourceAction.first_or_create(value: v) } if p[:actions]
      doc.resource_authors = (p[:authors] || []).map { |v| ResourceAuthor.first_or_create(value: v) } if p[:authors]
      doc.resource_climate_changes = (p[:climate_changes] || []).map {|v| ResourceClimateChange.first_or_create(value: v) } if p[:climate_changes]
      doc.resource_effects = (p[:effects] || []).map { |v| ResourceEffect.first_or_create(value: v) } if p[:effects]
      doc.resource_keywords = (p[:keywords] || []).map {|v| ResourceKeyword.first_or_create(value: v) } if p[:keywords]
      doc.resource_publishers = (p[:publishers] || []).map {|v| ResourcePublisher.first_or_create(value: v) } if p[:publishers]
      doc.resource_sectors = (p[:sectors] || []).map {|v| ResourceSector.first_or_create(value: v) } if p[:sectors]
      doc.resource_strategies = (p[:strategies] || []).map {|v| ResourceStrategy.first_or_create(value: v) } if p[:strategies]
      doc.resource_states = (p[:states] || []).map {|v| ResourceState.first_or_create(value: v) } if p[:states]

    end
  end


end
