class ResourceStrategyLink
  include DataMapper::Resource
  property :id, Serial
  property :resource_id, Integer, required: true,  unique_index: :unique_resource_geofocus_indx
  property :resource_strategy_id, Integer, required: true,  unique_index: :unique_resource_geofocus_indx

  belongs_to :resource
  belongs_to :resource_strategy
end
