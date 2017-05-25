module Models
  class Resource
    include DataMapper::Resource
    property :id, Serial
    property :name, String
    property :document_url, String
    belongs_to :sector

    def to_hash
      self.attributes.slice(:name, :id, :document_url)
    end
  end
end
