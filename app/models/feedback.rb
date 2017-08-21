class Feedback
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 128
  property :email, String, required: true, length: 128
  property :organization, String, length: 128
  property :phone, String, length: 128
  property :comment, String, length: 1024
  property :contact, Boolean

  def to_resource
    self.attributes
  end
end
