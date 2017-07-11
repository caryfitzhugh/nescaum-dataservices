class Action
  include DataMapper::Resource
  property :id, Serial
  property :table, String, length: 512, required: true
  property :record_id, Integer, required: true
  belongs_to :user, required: true
  property :description, String, length: 512, required: true

  def track!(record, user, msg)
    table = record.class.storage_names[record.class.repository.name]
    Action.create!(table: table, record_id: record.id, user: user, description: msg)
  end

  def to_resource
    self.attributes
  end
end
