require 'dm-postgis'
require 'georuby'
require 'geo_ruby/geojson'

class ClimateData
  include DataMapper::Resource
  def self.default_repository_name
    :geoserver
  end
  property :geomtype, String
  property :uid, String, :key => true
  property :variable_name, String
  property :geom, PostGISGeometry
  property :name, String, :key => true
  property :data, Json
end
