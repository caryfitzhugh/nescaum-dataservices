class ResourceAuthor
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_author_links

  def self.add_to_resource!(resource, value)
    ra = ResourceAuthor.first_or_create(value: value)
    ResourceAuthorLink.first_or_create(resource: resource, resource_author: ra)
  end
end
