class Action
  include DataMapper::Resource
  property :id, Serial
  property :table, String, length: 512, required: true
  property :record_id, Integer, required: true
  belongs_to :user, required: true
  property :at, DateTime, required: true
  property :description, String, length: 512, required: true

  def self.track!(record, user, msg)
    table = record.class.storage_names[record.class.repository.name]
    action = Action.new(table: table, record_id: record.id, user_id: user.id, description: msg,
                        at: Time.now.utc.to_datetime)
    if action.save
      action
    else
      raise action.errors.full_messages.join("\n")
    end
  end

  def to_resource
    attrs = self.attributes.merge(
      at: self.at.rfc3339,
      identifier: ""
    )
    if self.table == 'resources'
      resource = Resource.first(id: self.record_id)
      attrs[:identifier] = resource.title if resource
    end
    attrs
  end
end
