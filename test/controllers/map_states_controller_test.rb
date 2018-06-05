require 'test_helper'

class MapStatesControllerTest < NDSTestBase
  def test_set_and_retrieve
    post "/map_states/"
    binding.pry
    post_json "/map_states", {"map_state" => { data: "DATA" }}
    puts response.body
    assert response.ok?

    token = json_response['token']

    get "/map_states/" + token
    assert response.ok?

    assert_equal "DATA", json_response['data']
  end
end
