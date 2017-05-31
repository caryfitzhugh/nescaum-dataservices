module Models
  class Resource
    include DataMapper::Resource
    property :actions, DataMapper::Property::PgArray
    property :authors, DataMapper::Property::PgArray
    property :climate_changes, DataMapper::Property::PgArray
    property :content, String # Markdown syntax
    property :effects, DataMapper::Property::PgArray
    property :format, String, required: true
    property :geofocus, DataMapper::Property::PgArray
    property :id, Serial
    property :keywords, DataMapper::Property::PgArray
    # {type: "weblink", url: "url"} , ...]
    property :external_data_links, DataMapper::Property::PgArray
    property :published_on_end, Date
    property :published_on_start, Date
    property :publishers, DataMapper::Property::PgArray
    property :sectors, DataMapper::Property::PgArray
    property :states, DataMapper::Property::PgArray
    property :strategies, DataMapper::Property::PgArray
    property :subtitle, String
    property :title, String, required: true

    def self.get_by_docid(did)
      id = did.split("::").last.to_i
      Models::Resource.get(id)
    end

    def docid
      "#{self.class.name.downcase}::#{self.id}"
    end

    def to_search_document(search_terms: true)
      attributes = {
        actions: self.actions || [],
        authors: self.authors || [],
        climate_changes: self.climate_changes || [],
        content: self.content,
        effects: self.effects || [],
        formats: [self.format],
        geofocus: self.geofocus || [],
        docid: self.docid,
        keywords: self.keywords || [],
        links: self.external_data_links || [],
        pubend: self.published_on_end,
        publishers: self.publishers,
        pubstart: self.published_on_start,
        sectors: self.sectors || [],
        states: self.states || [],
        strategies: self.strategies || [],
        title: self.title,
        subtitle: self.subtitle,
      }
      attributes[:docid] = self.docid

      [ :sectors,
        :formats,
        :actions,
        :keywords,
        :strategies,
        :climate_changes,
        :effects].each do |key|
        attributes[key] = (attributes[key] ||= []).reduce([]) do |memo, attr|
          memo.concat(Models::Resource.expand_literal(attr))
        end
      end
      [:pubstart, :pubend].each do |key|
        attributes[key] = to_cs_date(attributes[key]) if attributes[key]
      end

      if search_terms
        attributes[:search_terms] = JSON.generate(attributes).gsub(/\W+/, " ")
      end

      attributes
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def self.expand_literal(literal_str)
      parts = literal_str.split("::")
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
end
