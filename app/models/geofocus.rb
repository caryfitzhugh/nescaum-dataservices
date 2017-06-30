class Geofocus
  include DataMapper::Resource
  property :id, Serial
  property :name, String, length: 512, unique: true, required: true
  has n, :geofocus_resources

  def to_resource
    self.attributes
  end
end
