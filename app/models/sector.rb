module Models
  class Sector
    include DataMapper::Resource
    has n,
    property :id, Serial
    property :name, String, required: true, unique: true
    belongs_to :resource
  end
end
