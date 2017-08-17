class Collection
  include DataMapper::Resource
  property :id, Serial
  property :name, String, length: 512, unique: true, required: true
  property :resources, DataMapper::Property::PgArray

  def to_resource
    attrs = self.attributes
    attrs[:resources] = attrs[:resources].map do |docid|
      Resource.get_by_docid(docid)
    end.compact.map(&:to_resource)
    attrs
  end
end
