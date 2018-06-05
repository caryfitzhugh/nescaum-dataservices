require 'dm-postgis'
require 'georuby'
require 'geo_ruby/geojson'
#require "geo_ruby/ewk"
require 'ostruct'

class Geofocus
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 512, required: true, unique_index: :unique_on_name_and_type
  property :type, String, length: 128, required: true, default: "custom", unique_index: :unique_on_name_and_type
  property :uid, String, length: 128
  property :geom, PostGISGeometry

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

  def self.calculate_area_and_centroid(geofocuses)
    if geofocuses.nil? || geofocuses.empty?
      nil
    else
      res = self.repository.adapter.select("
        SELECT
          ST_Area(collected_geoms.geom_sum) As area,
          ST_Centroid(collected_geoms.geom_sum) As centroid
        FROM ( SELECT
          ST_Multi(ST_Collect(geofocuses.geom)) As geom_sum
            FROM geofocuses
            WHERE id IN ? AND geom IS NOT NULL) as collected_geoms", geofocuses.map(&:id))[0].tap do |blob|
              if blob && blob.centroid
                blob.centroid = GeoRuby::SimpleFeatures::Point.from_hex_ewkb(blob.centroid)
              end
            end

       if res && res.centroid && res.area
         res
       else
         nil
       end
    end
  end

  def to_resource
    self.attributes
  end

  def to_geojson
    {"type": "Feature",
     "geometry": self.geom.as_json,
     "properties": {
        "name": self.name,
        "uid": self.uid,
        "id": self.id
      }
     }
  end

end
