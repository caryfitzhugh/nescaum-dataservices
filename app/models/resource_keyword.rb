class ResourceKeyword
  include DataMapper::Resource

  property :id, Serial
  property :value, String, required: true, index: true, unique: true, length: 256

  has n, :resource_keyword_links

  before :save, :downcase
  def downcase
    self.value = self.value.downcase if self.value
  end

  def self.add_to_resource!(resource, value)
    ra = ResourceKeyword.first_or_create(value: value)
    ResourceKeywordLink.first_or_create(resource: resource, resource_keyword: ra)
  end
end
