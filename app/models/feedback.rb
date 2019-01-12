class Feedback
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 128
  property :email, String, required: true, length: 128
  property :organization, String, length: 128
  property :phone, String, length: 128
  property :comment, String, length: 1024
  property :contact, Boolean
  property :sent, Boolean, default: false

  def to_resource
    self.attributes
  end

  def mark_sent!
    self.sent = true
    self.save!
  end
end
