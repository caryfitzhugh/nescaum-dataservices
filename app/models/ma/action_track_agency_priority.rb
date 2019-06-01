require 'dm-postgis'

module MA
  class ActionTrackAgencyPriority
    include DataMapper::Resource
    property :name, String, :unique => true
    property :id, Integer, :key => true
  end
end
