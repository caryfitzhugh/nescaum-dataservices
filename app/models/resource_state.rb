class ResourceState
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true

  has n, :resource_state_links

  def self.add_to_resource!(resource, value)
    ra = ResourceState.first_or_create(value: value)
    ResourceStateLink.first_or_create(resource: resource, resource_state: ra)
  end
end
