require 'test_helper'

class GeofocusResourceTest < NDSTestBase
  def test_creation
    gf = Geofocus.create(name: "HI")
    GeofocusResource.create!(resource: create_resource, geofocus: gf)
    GeofocusResource.create!(resource: create_resource, geofocus: gf)
    GeofocusResource.create!(resource: create_resource, geofocus: gf)
    assert_equal 3, gf.geofocus_resources.count
  end

  private

  def create_resource
    doc = Resource.new
    doc.content = "### Abstract"
    doc.authors = ["Cary FitzHugh", "Steve Signell"]
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.content_types = ["document::report"]
    doc.published_on_start = Date.today
    doc.published_on_end = Date.today
    doc.save!
    doc
  end
end
