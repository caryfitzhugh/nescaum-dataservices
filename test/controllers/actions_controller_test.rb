require 'test_helper'

class ActionsControllerTest < NDSTestBase
  def test_retrieval
    login_curator!
    user = User.create!(username: "Foo", password: "password")

    get "/actions", page: 1, per_page: 1
    assert response.ok?
    assert_equal 0, json_response['total']

    action  =Action.create!(table: "test", record_id: 1, user: user, description: "FOO")

    get "/actions", page: 1, per_page: 1

    assert response.ok?
    assert_equal 1, json_response['total']
    assert_equal 1, json_response['actions'].length

    get "/actions", page: 2, per_page: 1
    assert response.ok?
    assert_equal 0, json_response['actions'].length
    assert_equal 1, json_response['total']

    get "/actions", user_id: 4, page: 1, per_page: 1
    assert response.ok?
    assert_equal 0, json_response['total']

    get "/actions", user_id: user.id, page: 1, per_page: 1
    assert response.ok?
    assert_equal 1, json_response['total']
  end
end
