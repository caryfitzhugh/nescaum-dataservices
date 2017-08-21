class Suggestion
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 128
  property :email, String, required: true, length: 128
  property :organization, String, length: 128
  property :phone, String, length: 128
  property :title, String, length: 1024
  property :description, String, length: 2048
  property :type, String
  property :href, String, length: 1024
  property :source, String, length: 1024
  property :sectors, PgArray
  property :keywords, String, length: 1024


  def to_resource
    self.attributes
  end
end
