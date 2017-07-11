class Collection
  include DataMapper::Resource
  property :id, Serial
  property :name, String, length: 512, unique: true, required: true
  property :resources, DataMapper::Property::PgArray

  def to_resource
    self.attributes
  end
end
