class ResourceContentType
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_content_type_links

  def self.add_to_resource!(resource, value)
    ra = ResourceContentType.first_or_create(value: value)
    ResourceContentTypeLink.first_or_create(resource: resource, resource_content_type: ra)
  end
end
