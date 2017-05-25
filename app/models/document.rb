module Models
  class Document
    include DataMapper::Resource
    include Models::Resource
    property :id, Serial
    property :title, String, required: true
    property :type, String, required: true
    property :weblink_url, URI

    def self.all_types
      repository.adapter.select("SELECT DISTINCT type FROM models_documents")
    end
  end
end
