class ResourceSector
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_sector_links

  before :save, :downcase
  def downcase
    self.value = self.value.downcase if self.value
  end

  def self.add_to_resource!(resource, value)
    ra = ResourceSector.first_or_create(value: value)
    ResourceSectorLink.first_or_create(resource: resource, resource_sector: ra)
  end
end
