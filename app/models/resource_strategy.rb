class ResourceStrategy
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_strategy_links

  before :save, :downcase
  def downcase
    self.value = self.value.downcase if self.value
  end

  def self.add_to_resource!(resource, value)
    ra = ResourceStrategy.first_or_create(value: value)
    ResourceStrategyLink.first_or_create(resource: resource, resource_strategy: ra)
  end
end
