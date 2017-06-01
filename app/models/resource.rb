module Models
  class Resource
    include DataMapper::Resource

    property :id, Serial

    PROPERTIES = {
      actions:                {type: DataMapper::Property::PgArray, facet: true, expanded: true,  example: ["Emissions Reduction::multiple actions"]},
      authors:                {type: DataMapper::Property::PgArray, facet: true, expanded: false, example: ["C.S. Lewis", "Northeast Regional Climate Center (NRCC)"]},
      content:                {type: String , description: "Markdown content describing the resource", example: "###Content"},
      climate_changes:        {type: DataMapper::Property::PgArray, facet: true, expanded: true, example: ["Precipitation::Heavy Precipitation"]},
      # {type: "weblink", url: "url"} , ...]
      external_data_links:    {type: DataMapper::Property::PgArray, cs_name: :links, example: ["pdf::http://www.com/pdf", "weblink::http://google.com"]},
      effects:                {type: DataMapper::Property::PgArray, facet: true, expanded: true, example: ["Specific Vulnerability::Coastal Property Damage"]},
      formats:                {type: DataMapper::Property::PgArray, facet: true, expanded: true, required: true, example: ["Documents::Report"]},
      geofocus:               {type: DataMapper::Property::PgArray, facet: true, expanded: true, example: ["Ulster County, NY", "Westchester County, NY", "Maine Coastland"]},
      keywords:               {type: DataMapper::Property::PgArray, facet: true, expanded: false, example: ["dams::noexpanded", "floods", "land cover change"]},
      publishers:             {type: DataMapper::Property::PgArray, facet: true, expanded: true, example: ["NOAA", "NESCAUM", "The Disney Corporation"]},
      published_on_end:       {type: Date, cs_name: :pubend , example: "2017-01-31"},
      published_on_start:     {type: Date, cs_name: :pubstart, example: "2017-01-31" },
      sectors:                {type: DataMapper::Property::PgArray, facet: true, expanded: true, example: ["Ecosystems", "Water Resources"]},
      strategies:             {type: DataMapper::Property::PgArray, facet: true, expanded: true, example: ["Adaptation"]},
      states:                 {type: DataMapper::Property::PgArray, facet: true, expanded: true, example: ["NY", "MA"]},
      title:                  {type: String, required: true, example: "Title of the article"},
      subtitle:               {type: String, example: "A sub title of peace"},
    }
    FACETED_PROPERTIES = Hash[(PROPERTIES.each_pair.select do |(k,v)|
                                  v[:facet]
                                end)]

    DATE_PROPERTIES     = Hash[(PROPERTIES.each_pair.select do |(k,v)|
                                  v[:type] == Date
                                end)]

    TEXT_PROPERTIES     = Hash[(PROPERTIES.each_pair.select do |(k,v)|
                                  v[:type] == String
                                end)]
    PROPERTIES.each_pair do |name, attrs|
      property name, attrs[:type], required: !!attrs[:required]
    end

    def self.get_by_docid(did)
      id = did.split("::").last.to_i
      Models::Resource.get(id)
    end

    def self.search(query:'', filters:{}, page:1, per_page:100, pub_dates: [nil,nil])
      # We want facets for all the filters.
      # Facets:  { "actions": [1,2,3,4]}
      # Query: "tornado"
      args = {
        size: per_page,
        start: (page - 1) * per_page,
      }

      if query == "" || query.nil?
        args[:query] = "matchall"
        args[:query_parser] = "structured"
      else
        args[:query] = query
      end

      ## Filters
      filter_q = []

      filters = (filters || []).reduce([]) do |all, (fname, fvals)|
          [:or ].concat(fvals.map {|fval| "#{fname}:'#{fval.strip}'" })
        end
      filter_q.push(filters) unless filters.empty?

      ## Pubdate (range - squeezer!)
      filter_q.push([:and,"pubstart:['#{to_cs_date(pub_dates[0])}',]"]) if pub_dates[0]
      filter_q.push([:and,"pubend:[,'#{to_cs_date(pub_dates[1])}']"]) if pub_dates[1]

      # Scope to just our CS env
      filter_q.push([:and,"env:'#{CONFIG.cs.env}'"])

      args[:filter_query] = to_filter_query([:and].concat(filter_q))

      # Return facets for things
      args[:facet] = JSON.generate(FACETED_PROPERTIES.keys.reduce({}) do |memo, filter|
        memo[filter] = {:sort => :count, :size => 100}
        memo
      end)
      search_conn.search(args)
    end

    def docid
      "#{self.class.name.downcase}::#{self.id}"
    end

    def to_search_document(search_terms: true)
      attributes = PROPERTIES.reduce({}) do |memo, (name, attrs)|
        val = self.send(name)
        # Expand literals

        if attrs[:expanded]
          val = (val || []).reduce([]) do |memo, attr|
            memo.concat(Models::Resource.expand_literal(attr))
          end
        end

        if attrs[:type] == Date && val
          val = to_cs_date(val)
        end

        memo[attrs[:cs_name] || name] = val
        memo
      end
      attributes[:docid] = self.docid
      attributes[:search_terms] = JSON.generate(attributes).gsub(/\W+/, " ")

      attributes
    end

    def self.expand_literal(literal)
      if literal.is_a? Array
        literal.map {|v| expand_literal(v)}.reduce(&:concat)
      else
        parts = literal.split("::")
        last = parts.pop

        parts = parts.reduce([]) do |memo, obj|
            if memo.empty?
              memo.push(obj+"::")
            else
              memo.push("#{memo.last}#{obj}::")
            end
            memo
          end

        parts.push([parts.last , last].compact.join)
        parts
      end
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
