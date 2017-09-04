class ResourceClimateChange
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_climate_change_links

  before :save, :downcase
  def downcase
    self.value = self.value.downcase if self.value
  end

  def self.add_to_resource!(resource, value)
    ra = ResourceClimateChange.first_or_create(value: value)
    ResourceClimateChangeLink.first_or_create(resource: resource, resource_climate_change: ra)
  end
end
