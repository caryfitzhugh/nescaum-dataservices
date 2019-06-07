require 'dm-postgis'

module MA
  class ActionTrackPrimaryClimateInteraction
    include DataMapper::Resource
    property :name, String, :unique => true
    property :id, Integer, :key => true
  end
end
