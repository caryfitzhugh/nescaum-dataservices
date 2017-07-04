require 'test_helper'

class GeofocusControllerTest < NDSTestBase
  def test_crud_geofocus
    login_curator!
    post_json "/geofocuses", {"geofocus" => { "name": "Foo"}}

    assert response.ok?
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

    get "/geofocuses", {"q" => "Fo"}

    assert response.ok?
    assert_equal 4, Geofocus.count
    assert_equal 2, json_response.length
  end
end
