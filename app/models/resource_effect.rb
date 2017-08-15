class ResourceEffect
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true

  has n, :resource_effect_links

  def self.add_to_resource!(resource, value)
    ra = ResourceEffect.first_or_create(value: value)
    ResourceEffectLink.first_or_create(resource: resource, resource_effect: ra)
  end
end
