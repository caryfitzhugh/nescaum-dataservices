require 'test_helper'

class GeofocusTest < NDSTestBase
  def test_creation_duplicate
    assert_nothing_thrown do
      Geofocus.create!(name: "HI")
    end
    assert_raise do
      Geofocus.create!(name: "HI")
    end
  end

  def test_creation_polygon
    gf = Geofocus.new(name: "Custom GJSON")
    geom = GeoRuby::SimpleFeatures::Geometry.from_geojson(' { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [ [ [100.0, 0.0], [100.0, 10.0], [0.0, 10.0], [0.0, 0.0], [100.0, 0.0] ] ] }, "properties": { "prop0": "value0", "prop1": {"this": "that"} } } ')
    gf.geom = geom.geometry
    assert gf.save

    # Find inside the coords
    assert_equal [gf], Geofocus.find_containing_point([5,50])
    assert_equal [], Geofocus.find_containing_point([50,5])

    assert_equal [gf], Geofocus.find_inside_polygon([[0,0],[0,10],[10,10],[10,0],[0,0]])
    assert_equal [], Geofocus.find_inside_polygon([[-1,-1],[-1,-10],[-10,-10],[-10,-1],[-1,-1]])
  end
end
