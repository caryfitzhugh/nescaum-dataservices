require 'test_helper'

class ResourcesControllerTest < NDSTestBase
  def test_crud_resource
    login_curator!
    geofocus = Geofocus.create(name: "Test")
    post_json "/resources", {"resource" => {
      title: "Title",
      subtitle: "Subtitle",
      formats: ["format::1"],
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    }}

    js_resp = json_response

    assert response.ok?
    assert_equal "Title", js_resp['title']
    assert_equal "Subtitle", js_resp['subtitle']
    assert_equal ["format::1"], js_resp['formats']
    assert_equal geofocus.to_resource["id"], js_resp['geofocuses'][0][:id]
    assert_equal geofocus.to_resource["name"], js_resp['geofocuses'][0][:name]
  end

  def test_index_resource
    login_curator!
    geofocus = Geofocus.create(name: "Test")
    doc = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      formats: ["format::1"],
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    )

    post_json "/resources/#{doc.docid}/index", {}
    doc.reload
    assert_equal true, doc.indexed
    assert response.ok?
    wait_for_cs_sync!
  end

  def test_index_delete_resource
    login_curator!
    geofocus = Geofocus.create(name: "Test")
    doc = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      formats: ["format::1"],
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    )

    delete "/resources/#{doc.docid}/index", {}
    doc.reload
    assert_equal false, doc.indexed
    assert response.ok?
    wait_for_cs_sync!
  end

  def test_search_resource
    geofocus1 = Geofocus.create(name: "GF1")
    doc = Resource.create!(
      title: "Title1",
      subtitle: "Subtitle",
      formats: ["format::1"],
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus1.id],
    )
    doc.sync_index!

    # GF Doc 2 - has same fields but different GF
    geofocus2 = Geofocus.create(name: "GF2")
    doc2 = Resource.create!(
      title: "Title2",
      subtitle: "Subtitle",
      formats: ["format::2"],
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus2.id],
    )

    # GF Doc 3 - has same fields but no GF
    doc2 = Resource.create!(
      title: "Title3",
      subtitle: "Subtitle",
      formats: ["format::3"],
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [],
    )

    wait_for_cs_sync!

    get "/resources", page: 1, per_page: 1
    jr = json_response

    assert_equal 3, jr['hits']
    assert_equal 1, jr['resources'].length
    assert_equal 4, jr['facets']['formats'].length


    get "/resources", page: 1, per_page: 5
    jr = json_response
    assert_equal 3, jr['hits']
    assert_equal 3, jr['resources'].length
    assert_equal 4, jr['facets']['formats'].length

    get "/resources", page: 1, per_page: 5, geofocuses: "#{geofocus1.id}"
    jr = json_response
    assert_equal 1, jr['hits']
    assert_equal 1, jr['resources'].length
    assert_equal 2, jr['facets']['formats'].length
    # Should have 1 hit

    get "/resources", page: 1, per_page: 5, geofocuses: "#{geofocus1.id},#{geofocus2.id}"
    jr = json_response
    assert_equal 2, jr['hits']
    assert_equal 2, jr['resources'].length
    assert_equal 3, jr['facets']['formats'].length

    get "/resources", page: 1, per_page: 5, query: "Title1"
    # should have 1 hit
    jr = json_response
    assert_equal 1, jr['hits']
    assert_equal 1, jr['resources'].length
    assert_equal 2, jr['facets']['formats'].length

    get "/resources", page: 1, per_page: 5, formats: "format::"
    # Should have 3 hits
    jr = json_response
    assert_equal 3, jr['hits']
    assert_equal 3, jr['resources'].length
    assert_equal 4, jr['facets']['formats'].length

    get "/resources", page: 1, per_page: 5, formats: "format::3"
    # should have 1 hit
    jr = json_response
    assert_equal 1, jr['hits']
    assert_equal 1, jr['resources'].length
    assert_equal 2, jr['facets']['formats'].length
  end
end
