require 'dm-postgis'
require 'georuby'
require 'geo_ruby/geojson'
#require "geo_ruby/ewk"

class Geofocus
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 512, unique: true, required: true
  property :type, String, length: 128, required: true, default: "custom"
  property :state, String, length: 50
  property :uid, String, length: 128
  property :geom, PostGISGeometry, :index => true

  has n, :geofocus_resources
  def self.struct_to_geofocus(stct)
      attrs = {}
      stct.each_pair do |k,v|
        attrs[k.to_sym] = v
      end
      Geofocus.new(attrs)

  end
  def self.find_containing_point(latlng)
    self.repository.adapter.select("SELECT * FROM geofocuses WHERE ST_Contains(geofocuses.geom, ST_Transform( ST_GeomFromText(?, 4326), 4326))",
                                   "POINT(#{latlng[1]} #{latlng[0]})").map do |stct|
      self.struct_to_geofocus(stct)
    end
  end

  def self.find_inside_polygon(points)
    self.repository.adapter.select("SELECT * FROM geofocuses WHERE ST_Intersects(geofocuses.geom, ST_Transform( ST_GeomFromText(?, 4326), 4326))",
                                   "POLYGON((#{points.map {|p| "#{p[1]} #{p[0]}"}.join(",")}))").map do |stct|
      self.struct_to_geofocus(stct)
    end
  end

  def to_resource
    self.attributes.clone.tap do |attrs|
      attrs[:geom] = attrs[:geom].to_json
    end
  end
end
