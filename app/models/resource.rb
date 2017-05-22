require 'data_mapper'

module Models
  class Resource
    include DataMapper::Resource
    property :id, Serial
    property :name, String
    property :document_url, String

    def self.find
      Resource.all
    end

    def to_hash
      self.attributes.slice(:name, :id, :document_url)
      #{name: self.name,
       #id: self.id,
       #document_url: self.document_url,
      #}
    end
  end
end
