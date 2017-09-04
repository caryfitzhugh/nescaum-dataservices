class ResourceStrategy
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true

  has n, :resource_strategy_links

  before :save, :downcase
  def downcase
    value = value.downcase
  end

  def self.add_to_resource!(resource, value)
    ra = ResourceStrategy.first_or_create(value: value)
    ResourceStrategyLink.first_or_create(resource: resource, resource_strategy: ra)
  end
end
