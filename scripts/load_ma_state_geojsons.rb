require 'json'
require 'open-uri'
require 'georuby'

require './nds_app'
class String
  def titleize
    u_split = split("_")
    s_split = u_split.map { |s| s.split(" ") }.flatten

    if s_split.empty?
      capitalize
    else
      s_split.map(&:capitalize).join(" ")
    end
  end
end

#  https://raw.githubusercontent.com/NewtonMAGIS/GISData/master/Massachusetts%20Town%20Boundaries/MassTowns.geojson
#    mapshaper.org
#    dissolve 'TOWN'
#    simplify to 2%
#    export (600kb)

FILENAME = File.join(File.dirname(__FILE__), 'masstowns.geojson')
puts "Loaded data"
data = JSON.load(File.read(FILENAME))

towns = {}

data['features'].each do |feature|
  props = feature['properties']
  name = props['TOWN'].titleize + ", MA"
  geofocus = Geofocus.first(:name => name)
  if geofocus
    puts "existing"
  else
    geofocus = Geofocus.new
    geofocus.name = name
    geofocus.type = 'town'
  end

  if geofocus.geom
    puts "Skipping..."
  else
    geofocus.geom = GeoRuby::SimpleFeatures::Geometry.from_geojson(JSON.dump(feature['geometry']))
  end

  geofocus.save!
  puts "Updated ", name, geofocus.id
end
