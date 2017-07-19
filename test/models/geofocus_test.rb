require 'test_helper'

class GeofocusTest < NDSTestBase
  def test_creation_duplicate
    assert_nothing_thrown do
      Geofocus.create!(name: "HI", type: "foo")
    end
    assert_raise do
      Geofocus.create!(name: "HI", type: "foo")
    end
    assert_nothing_thrown do
      Geofocus.create!(name: "HI", type: "foo2")
    end
  end
  def test_get_area_centroid
    gf = Geofocus.new(name: "Custom GJSON")
    geom = GeoRuby::SimpleFeatures::Geometry.from_geojson(' { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [ [ [100.0, 0.0], [100.0, 10.0], [0.0, 10.0], [0.0, 0.0], [100.0, 0.0] ] ] }, "properties": { "prop0": "value0", "prop1": {"this": "that"} } } ')
    gf.geom = geom.geometry
    assert gf.save

    gf2 = Geofocus.new(name: "Custom GJSON2")
    geom2 = GeoRuby::SimpleFeatures::Geometry.from_geojson(' { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [ [ [-100.0, 0.0], [-100.0, -10.0], [0.0, -10.0], [0.0, 0.0], [-100.0, 0.0] ] ] }, "properties": { "prop0": "value0", "prop1": {"this": "that"} } } ')
    gf2.geom = geom2.geometry
    assert gf2.save

    area_and_centroid = Geofocus.calculate_area_and_centroid([gf, gf2])
    assert_equal 2000.0, area_and_centroid.area
    assert_equal GeoRuby::SimpleFeatures::Geometry.from_geojson("{\"type\":\"Point\",\"coordinates\":[-0.0,-0.0]}"), area_and_centroid.centroid

    area_and_centroid = Geofocus.calculate_area_and_centroid([gf])
    assert_equal 1000.0, area_and_centroid.area
    assert_equal GeoRuby::SimpleFeatures::Geometry.from_geojson("{\"type\":\"Point\",\"coordinates\":[50.0,5.0]}"), area_and_centroid.centroid

    area_and_centroid = Geofocus.calculate_area_and_centroid([gf2])
    assert_equal 1000.0, area_and_centroid.area
    assert_equal GeoRuby::SimpleFeatures::Geometry.from_geojson("{\"type\":\"Point\",\"coordinates\":[-50.0,-5.0]}"), area_and_centroid.centroid

    # Blank
    area_and_centroid = Geofocus.calculate_area_and_centroid([])
    assert_equal nil, area_and_centroid
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
