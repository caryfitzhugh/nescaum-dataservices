require 'test_helper'

class ActionsControllerTest < NDSTestBase
  def test_retrieval
    login_curator!
    user = User.create!(username: "Foo", password: "password")

    get "/actions", page: 1, per_page: 1
    assert response.ok?
    assert_equal 0, json_response['total']

    action  =Action.create!(table: "test", record_id: 1, at: Time.now.utc.to_datetime, user: user, description: "FOO")

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

  def test_resource_actions
    login_curator!

    get "/actions"
    assert response.ok?
    assert_equal 0, json_response['total']

    geofocus = Geofocus.create(name: "Test")
    post_json "/resources", {"resource" => {
      title: "Title",
      subtitle: "Subtitle",
      content_types: ["format::1"],
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    }}
    assert response.ok?

    get "/actions"
    assert response.ok?
    assert_equal 1, json_response['total']

    put_json "/resources/#{Resource.last.id}", {"resource" => {
      title: "Title2"
    }}
    assert response.ok?

    get "/actions"
    assert response.ok?
    assert_equal 2, json_response['total']

    ## Complete - searching via user
    get "/actions", user_id: User.last.id + 1
    assert response.ok?
    assert_equal 0, json_response['total']

    get "/actions", user_id: User.last.id
    assert response.ok?
    assert_equal 2, json_response['total']

    #  Complete - searching via date range
    sleep 1
    get "/actions", end: Time.now.utc.to_datetime.rfc3339
    assert response.ok?
    assert_equal 2, json_response['total']

    get "/actions", start: Time.now.utc.to_datetime.rfc3339
    assert response.ok?
    assert_equal 0, json_response['total']
  end
end
