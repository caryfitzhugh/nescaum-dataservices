require 'dm-postgis'

module MA
  class ActionTrackSector
    include DataMapper::Resource
    property :name, String, :unique => true
    property :id, Integer, :key => true
  end
end
