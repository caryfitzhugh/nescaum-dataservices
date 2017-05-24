module Models
  class Sector
    include DataMapper::Resource
    property :id, Serial
    property :name, String, required: true, unique: true
  end
end
