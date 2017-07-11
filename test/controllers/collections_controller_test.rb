require 'test_helper'

class CollectionControllerTest < NDSTestBase
  def test_crud_collection
    login_curator!
    post_json "/collections", {"collection" => {"name": "Foo", "resources": ["doc1", "doc2"]}}

    assert response.ok?
    assert_equal 1, Collection.count

    get "/collections/#{Collection.last.id}"
    assert response.ok?
    assert_equal "Foo", json_response["name"]

    delete "/collections/#{Collection.last.id}"
    assert response.ok?
    assert_equal 0, Collection.count
  end

  def test_update_collection
    Collection.create!(name: "Foo", "resources": ["doc1","doc2"])

    get "/collections/#{Collection.last.id}"
    assert response.ok?
    assert_equal "Foo", json_response["name"]
    assert_equal ['doc1','doc2'], json_response["resources"]

    put_json "/collections/#{Collection.last.id}", {"collection": {"resources": ["doc2","doc1"], "name": "Bar"}}
    assert response.ok?
    assert_equal "Bar", json_response["name"]
    assert_equal ['doc2','doc1'], json_response["resources"]
  end
end
