class ResourcePublisher
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_publisher_links

  def self.add_to_resource!(resource, value)
    ra = ResourcePublisher.first_or_create(value: value)
    ResourcePublisherLink.first_or_create(resource: resource, resource_publisher: ra)
  end
end
