class ResourceAction
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_action_links

  before :save, :downcase
  def downcase
    self.value = self.value.downcase if self.value
  end

  def self.add_to_resource!(resource, value)
    ra = ResourceAction.first_or_create(value: value)
    ResourceActionLink.first_or_create(resource: resource, resource_action: ra)
  end
end
