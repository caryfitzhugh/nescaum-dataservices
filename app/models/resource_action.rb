class ResourceAction
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true

  has n, :resource_action_links

  def self.add_to_resource!(resource, value)
    ra = ResourceAction.first_or_create(value: value)
    ResourceActionLink.first_or_create(resource: resource, resource_action: ra)
  end
end
