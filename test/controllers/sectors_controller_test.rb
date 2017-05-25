require 'test_helper'

class SectorsControllerTest < NDSTestBase
  def test_sectors_index
    visit "/sectors"
    assert last_response.ok?
    assert_equal json_response, []

    Models::Sector.create(name: "Sector")

    visit "/sectors"
    assert last_response.ok?
    assert_equal json_response.length, 1
    assert_equal json_response.first["name"], "Sector"
  end

  def test_sectors_index_query
    Models::Sector.create(name: "Sector")

    visit url_for("/sectors", name: "Sec")
    assert last_response.ok?
    assert_equal json_response.length, 1
    assert_equal json_response.first["name"], "Sector"

    visit url_for("/sectors", name: "Not")
    assert last_response.ok?
    assert_equal json_response.length, 0
  end

  def test_sectors_create_inaccessible
    post_sector({"name": "Sector"})
    assert !last_response.ok?
  end

  def test_sectors_create
    login_curator!
    post_sector({"name": "Sector"})
    assert last_response.ok?

    post_sector({"name": "Sector"})
    assert_equal last_response.status, 400
  end

  def test_sectors_delete_inaccessible
    delete_sector(100)
    assert_equal last_response.status, 403
  end

  def test_sectors_delete
    login_curator!
    delete_sector(100)
    assert_equal last_response.status, 404, last_response.body

    sector = Models::Sector.create(name: "testSec")
    delete_sector(sector.id)
    assert last_response.ok?
  end

  private
  def delete_sector(id)
    delete url_for("/sectors/#{id}")
  end
  def post_sector(attrs)
    post_json(url_for("/sectors"), {"sector": attrs})
  end
end
