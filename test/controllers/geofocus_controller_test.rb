require 'test_helper'

class GeofocusControllerTest < NDSTestBase
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
