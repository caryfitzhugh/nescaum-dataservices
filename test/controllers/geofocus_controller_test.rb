require 'test_helper'

class GeofocusControllerTest < NDSTestBase
  def test_bulk_geojson
    gj = File.read("test/data/large.geo.json")
    geom = GeoRuby::SimpleFeatures::Geometry.from_geojson(gj).geometry

    gf = Geofocus.new(name:"LaRgEr", geom: geom)
    assert gf.save

    gf2 = Geofocus.new(name: "MNumasdf", geom: geom)
    assert gf2.save

    get "/geofocuses/bulk_geojson", {"ids": [gf.id, gf2.id].join(",")}
    assert response.ok?
  end

  def test_create_gf
    geom = '{ "type": "Feature", "properties": { "STATEFP": "25", "COUNTYFP": "011", "COUNTYNS": "00606932", "AFFGEOID": "0500000US25011", "GEOID": "25011", "NAME": "Franklin", "LSAD": "06", "ALAND": 1811271672, "AWATER": 65368074 }, "geometry": { "type": "Polygon", "coordinates": [ [ [ -72.92949771078592, 42.73835794706574 ], [ -72.86412446590863, 42.73711172225538 ], [ -72.8093522877682, 42.73586549744502 ], [ -72.51605610804847, 42.72838814858287 ], [ -72.45775024099576, 42.727141923772514 ], [ -72.4506828631712, 42.727141923772514 ], [ -72.41181228513605, 42.725895698962155 ], [ -72.28283263983761, 42.72215702453108 ], [ -72.27223157310075, 42.67480048173746 ], [ -72.2245267727849, 42.63865996223708 ], [ -72.27576526201304, 42.576348721719164 ], [ -72.27046472864461, 42.546439326270566 ], [ -72.24396206180246, 42.51279125639089 ], [ -72.29166686211832, 42.47914318651122 ], [ -72.31463584004818, 42.34330468218217 ], [ -72.35527326253947, 42.30342548825071 ], [ -72.37470855155705, 42.420570620424385 ], [ -72.48248606338176, 42.40686214751044 ], [ -72.48955344120634, 42.43303286852797 ], [ -72.66800473127677, 42.409354597131156 ], [ -72.69980793148734, 42.452972465493694 ], [ -72.75811379854007, 42.44549511663155 ], [ -72.8711918437332, 42.48412808575265 ], [ -72.87649237710164, 42.54145442702913 ], [ -72.97543566664564, 42.55516289994307 ], [ -72.95069984425965, 42.641152411857796 ], [ -72.94893299980349, 42.7034636523757 ], [ -73.0231404669615, 42.740850396686454 ], [ -73.01783993359307, 42.740850396686454 ], [ -72.92949771078592, 42.73835794706574 ] ] ] } }'
    login_curator!
    post_json "/geofocuses", {"geofocus" => { "name": "Foo", type: "City", uid: "123", geom: geom}}
    assert response.ok?
  end
  def test_crud_geofocus
    login_curator!
    post_json "/geofocuses", {"geofocus" => { "name": "Foo", type: "City", uid: "123",
      geom:'{ "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [ [ [100.0, 0.0], [100.0, 10.0], [0.0, 10.0], [0.0, 0.0], [100.0, 0.0] ] ] }, "properties": { "prop0": "value0", "prop1": {"this": "that"} } } '
    }}

    assert response.ok?
    assert_equal 1, Geofocus.count

    assert_equal 1, Geofocus.count

    delete "/geofocuses/#{Geofocus.last.id}"
    assert response.ok?
    assert_equal 0, Geofocus.count
  end

  def test_search_geofocus
    Geofocus.create!(name: "Foo")
    Geofocus.create!(name: "Food")
    Geofocus.create!(name: "Good")
    Geofocus.create!(name: "Bad")
    get "/geofocuses"
    assert response.ok?
    assert_equal Geofocus.count, json_response['geofocuses'].length

    get "/geofocuses", {"q" => "Fo"}

    assert response.ok?
    assert_equal 4, Geofocus.count
    assert_equal 2, json_response['geofocuses'].length
  end

  def test_get_geojson
    login_curator!
    geojson ="{\"type\":\"Polygon\",\"coordinates\":[[[100.0,0.0],[100.0,10.0],[0.0,10.0],[0.0,0.0],[100.0,0.0]]]}"
    post_json "/geofocuses", {"geofocus" => { "name": "Foo", type: "City", uid: "123",
      geom:geojson
    }}

    assert response.ok?
    assert_equal 1, Geofocus.count

    get "/geofocuses/#{Geofocus.last.id}/geojson"
    assert response.ok?
    assert_equal geojson, response.body
  end
end
