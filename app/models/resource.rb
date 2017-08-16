require 'rgeo'

DataMapper::Inflector.inflections do |inflect|
  inflect.irregular "geofocus", "geofocuses"
  inflect.irregular "strategy", "strategies"
end

class Resource
  include DataMapper::Resource

  def self.custom_docid_prefix(prefix=:nil)
    @custom_docid_prefix = prefix unless prefix == :nil
    @custom_docid_prefix
  end
  FACETED_PROPERTIES = [
    :actions,
    :authors,
    :content_types,
    :climate_changes,
    :effects,
    :keywords,
    :publishers,
    :sectors,
    :strategies,
    :states
  ]

  property :id, Serial
  property :indexed, Boolean, default: false

  property :title, String, length: 1024
  property :subtitle, String, length: 1024
  property :image, String, length: 1024
  property :content,  String, length: 8192
  property :external_data_links, DataMapper::Property::PgArray
  property :published_on_end, Date, required: true
  property :published_on_start, Date, required: true
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :geofocus_resources
  has n, :geofocuses, through: :geofocus_resources

  def geofocuses=(newv)
    #if newv is just an int, look it up
    if newv.all? {|i| i.is_a?(Integer) }
      newv = Geofocus.all(id: newv)
    end
    super(newv)
  end

  has n, :resource_action_links
  has n, :resource_actions, through: :resource_action_links
  def actions=(action_strs)
    action_strs.each do |str|
      ResourceAction.add_to_resource!(self, str)
    end
  end

  has n, :resource_author_links
  has n, :resource_authors, through: :resource_author_links
  def authors=(action_strs)
    action_strs.each do |str|
      ResourceAuthor.add_to_resource!(self, str)
    end
  end

  has n, :resource_climate_change_links
  has n, :resource_climate_changes, through: :resource_climate_change_links
  def climate_changes=(strs)
    strs.each do |str|
      ResourceClimateChange.add_to_resource!(self, str)
    end
  end

# has n, :resource_effects
  has n, :resource_effect_links
  has n, :resource_effects, through: :resource_effect_links
  def effects=(strs)
    strs.each do |str|
      ResourceEffect.add_to_resource!(self, str)
    end
  end

# has n, :resource_keywords
  has n, :resource_keyword_links
  has n, :resource_keywords, through: :resource_keyword_links
  def keywords=(strs)
    strs.each do |str|
      ResourceKeyword.add_to_resource!(self, str)
    end
  end

# has n, :resource_publishers
  has n, :resource_publisher_links
  has n, :resource_publishers, through: :resource_publisher_links
  def publishers=(strs)
    strs.each do |str|
      ResourcePublisher.add_to_resource!(self, str)
    end
  end

# has n, :resource_content_types
  has n, :resource_content_type_links
  has n, :resource_content_types, through: :resource_content_type_links
  def content_types=(strs)
    strs.map do |str|
      ResourceContentType.first_or_create(value: str)
    end
  end

# has n, :resource_sectors
  has n, :resource_sector_links
  has n, :resource_sectors, through: :resource_sector_links
  def sectors=(strs)
    strs.each do |str|
      ResourceSector.add_to_resource!(self, str)
    end
  end


# has n, :resource_strategies
  has n, :resource_strategy_links
  has n, :resource_strategies, through: :resource_strategy_links
  def strategies=(strs)
    strs.each do |str|
      ResourceStrategy.add_to_resource!(self, str)
    end
  end

# has n, :resource_states
  has n, :resource_state_links
  has n, :resource_states, through: :resource_state_links
  def states=(strs)
    strs.each do |str|
      ResourceState.add_to_resource!(self, str)
    end
  end

  def self.get_by_docid(did)
    id = did.split("::").last.to_i
    Resource.get(id)
  end

  def self.all_by_docids(dids)
    ids = dids.map do |did|
        did.split("::").last.to_i
    end
    resources = Resource.all(id: ids)
    resources.sort_by do |resource|
      ids.index(resource.id)
    end
  end

  def self.search(query:'', filters:{}, bounding_box: nil, geofocuses: [], page:1, per_page:100, pub_dates: [nil,nil])
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
    filter_q.push([:and,"pubstart:['#{to_cs_date(pub_dates[0])}',}"]) if pub_dates[0]
    filter_q.push([:and,"pubend:{,'#{to_cs_date(pub_dates[1])}']"]) if pub_dates[1]
    filter_q.push([:or].concat(geofocuses.map {|gf| "geofocuses:#{gf}"})) unless geofocuses.empty?

    # Bounding boxen
    if bounding_box
      sw_lng = bounding_box[0]
      sw_lat = bounding_box[1]
      ne_lng = bounding_box[2]
      ne_lat = bounding_box[3]

      ring_coords = [
        [sw_lat, sw_lng],
        [sw_lat, ne_lng],
        [ne_lat, ne_lng],
        [ne_lat, sw_lng],
        [sw_lat, sw_lng],
      ]

      ring = GeoRuby::SimpleFeatures::LinearRing.from_coordinates(ring_coords, 4326)
      bbox = GeoRuby::SimpleFeatures::Polygon.from_linear_rings([ring])
      bbox_attrs = self.repository.adapter.select("SELECT ST_Centroid(geom) as centroid, ST_Area(geom) as area FROM (SELECT ST_GeomFromEWKT(?) as geom) as calc ", bbox.as_ewkt)[0]
      centroid = GeoRuby::SimpleFeatures::Point.from_hex_ewkb(bbox_attrs.centroid)

      area_delta = "((area - #{bbox_attrs.area})/(abs(area - #{bbox_attrs.area}) + 100))"
      distance = "(haversin(#{centroid.lat}, #{centroid.lng}, centroid.latitude, centroid.longitude))"
      args[:expr] = JSON.generate({
        "bbox_score" => "#{distance} * (#{area_delta} + 0.01)"
      })
      args[:return] = "docid,bbox_score"
      args[:sort] = "bbox_score asc"
    end

    # Scope to just our CS env
    filter_q.push([:and,"env:'#{CONFIG.cs.env}'"])

    args[:filter_query] = to_filter_query([:and].concat(filter_q))

    # Return facets for things
    args[:facet] = JSON.generate(FACETED_PROPERTIES.reduce({}) do |memo, filter|
      memo[filter] = {:sort => :count, :size => 1000}
      memo
    end)

    self.logger.info "Args: #{args}"

    Cloudsearch.search_conn.search(args)
  end

  def delete_associations
    self.resource_action_links.destroy
    self.resource_author_links.destroy
    self.resource_climate_change_links.destroy
    self.resource_effect_links.destroy
    self.resource_keyword_links.destroy
    self.resource_publisher_links.destroy
    self.resource_content_type_links.destroy
    self.resource_sector_links.destroy
    self.resource_strategy_links.destroy
    self.resource_state_links.destroy
    self.geofocus_resources.destroy
  end

  def destroy
    delete_associations
    super
  end

  def destroy!
    delete_associations
    super
  end

  def docid
    docid = "#{Resource.custom_docid_prefix}#{self.class.name.downcase}::#{self.id}"
    docid
  end

  def sync_index!
    if self.indexed
      Cloudsearch.add_documents([self.to_search_document])
    else
      Cloudsearch.remove_documents([self.docid])
    end
  end

  def to_resource
    {docid: self.docid,
     id: self.id,
     geofocuses: self.geofocuses.map(&:id),
     title: self.title,
     subtitle: self.subtitle,
     image: self.image,
     external_data_links: self.external_data_links,
     content: self.content,

     actions: self.resource_actions.map(&:value),
     authors: self.resource_authors.map(&:value),
     climate_changes: self.resource_climate_changes.map(&:value),
     effects: self.resource_effects.map(&:value),
     content_types: self.resource_content_types.map(&:value),
     keywords: self.resource_keywords.map(&:value),
     publishers: self.resource_publishers.map(&:value),
     sectors: self.resource_sectors.map(&:value),
     strategies: self.resource_strategies.map(&:value),
     states: self.resource_states.map(&:value),

     ## Dates
     published_on_start: to_cs_date(self.published_on_start),
     published_on_end:   to_cs_date(self.published_on_end),
    }
  end

  def to_search_document(search_terms: true)
    attributes = {}
    [
      [:actions, self.resource_actions, {:expand => true}],
      [:authors, self.resource_authors],
      [:climate_changes, self.resource_climate_changes, {:expand => true}],
      [:effects, self.resource_effects, {:expand => true}],
      [:content_types, self.resource_content_types, {:expand => true}],
      [:keywords, self.resource_keywords, {:expand => true}],
      [:publishers, self.resource_publishers],
      [:sectors, self.resource_sectors, {:expand => true}],
      [:strategies, self.resource_strategies, {:expand => true}],
      [:states, self.resource_states]
    ].each do |(cs_name, values, opts)|
      opts ||= {}
      attributes[cs_name] = values.map(&:value)
      if opts[:expand]
        attributes[cs_name] = attributes[cs_name].reduce([]) do |memo, v|
          memo.concat(Resource.expand_literal(v))
        end
      end
    end

    ## Dates
    attributes[:pubstart] = to_cs_date(self.published_on_start)
    attributes[:pubend]   = to_cs_date(self.published_on_end)

    attributes[:links] = self.external_data_links || []

    attributes[:title] = self.title
    attributes[:subtitle] = self.subtitle
    attributes[:content] = self.content

    attributes[:docid] = self.docid
    attributes[:search_terms] = JSON.generate(attributes).gsub(/\W+/, " ")
    attributes[:geofocuses] = self.geofocuses.map(&:id)

    area_and_centroid = Geofocus.calculate_area_and_centroid(self.geofocuses)
    if area_and_centroid
      attributes[:area] = area_and_centroid.area
      attributes[:centroid] = "#{area_and_centroid.centroid.lat},#{area_and_centroid.centroid.lng}"
    end

    # Remove any null / blank values
    attributes.select {|k,v| v}
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

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

end
