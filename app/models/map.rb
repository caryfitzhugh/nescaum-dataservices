module Models
  class Map
    include DataMapper::Resource
    include Models::Resource
    property :id, Serial
    property :title, String, required: true
    property :type, String, required: true
    property :weblink_url, URI
  end
end
