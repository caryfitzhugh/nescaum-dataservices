require 'test_helper'

class UsersControllerTest < NDSTestBase
  def test_retrieval
    user = User.create!(username: "Foo", password: "password")

    get "/users", page: 1, per_page: 1
    assert response.ok?
    assert_equal 1, json_response['total']
  end
end
