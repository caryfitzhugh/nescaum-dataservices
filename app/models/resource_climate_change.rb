class ResourceClimateChange
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true

  has n, :resource_climate_change_links

  before :save, :downcase
  def downcase
    value = value.downcase
  end

  def self.add_to_resource!(resource, value)
    ra = ResourceClimateChange.first_or_create(value: value)
    ResourceClimateChangeLink.first_or_create(resource: resource, resource_climate_change: ra)
  end
end
