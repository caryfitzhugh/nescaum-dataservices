class Geofocus
  include DataMapper::Resource
  property :id, Serial
  property :name, String, length: 512, unique: true, required: true
  has n, :geofocus_resources

  def add_to!(resource)
    ResourceGeofocus.first_or_create(resource: resource, geofocus: self)
  end
end
