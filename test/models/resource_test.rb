require 'test_helper'

class ResourceTest < NDSTestBase
  # /home/cfitzhugh/.rvm/gems/ruby-2.3.4@nescaum-dataservices/gems/aws-sdk-core-2.9.25/lib/aws-sdk-core/plugins/request_signer.rb : 89
  def test_geofocus
    doc = Resource.new
    doc.content = "### Abstract"
    doc.authors = ["Cary FitzHugh", "Steve Signell"]
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.content_types = ["document::report"]
    doc.published_on_start = Date.today
    doc.published_on_end = Date.today
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.save!
    # can we run this?
    doc.to_search_document
  end

  def test_cs_update
    doc = Resource.new
    doc.content = "### Abstract"
    doc.authors = ["Cary FitzHugh", "Steve Signell"]
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.content_types = ["document::report"]
    doc.published_on_start = Date.today
    doc.published_on_end = Date.today
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.indexed = true
    doc.save!

    doc.sync_index!
    wait_for_cs_sync!

    # THis is tricky.  Make sure you delete it after adding.
    # If you add after a delete - it can get confused and borked
    results = Resource.search()
    assert_equal results.hits.found, 1

    doc.indexed = false
    doc.save!
    doc.sync_index!

    wait_for_cs_sync!
    results = Resource.search()
    assert_equal results.hits.found, 0
  end

  def test_expand_literal
    [
      [['ok'], 'ok'],
      [['ok::','ok::too'], 'ok::too'],
      [['ok::','ok::too::', 'ok::too::three'], 'ok::too::three'],
    ].each do |desired, input|
      assert_equal desired, Resource.send(:expand_literal, input)
    end
  end

  def test_to_resource_def
    date = Date.today
    doc = Resource.new
    doc.content = "### Abstract"
    doc.authors = ["Cary FitzHugh", "Steve Signell"]
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.content_types = ["document::report"]
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.external_data_links = [
      "pdf::http://google.com/pdf",
      "weblink::http://google.com/weblink",
    ]
    doc.publishers = ["NOAA"]
    doc.image  = "http:123"
    doc.published_on_start = date
    doc.published_on_end = date
    doc.keywords = ["danger"]
    doc.sectors = ["root", "root2::leaf"]
    doc.effects = ["root", "root2::leaf"]
    doc.actions = ["root", "root2::leaf"]
    doc.climate_changes = ["root", "root2::leaf"]
    doc.strategies = ["adaptation"]
    doc.states = ["VT", "MA", "CT"]

    assert doc.save, doc.errors.full_messages.join("\n")

    doc_expected = {
                  :content=>"### Abstract",
                  :actions=>["root", "root2::", "root2::leaf"],
                  :authors=>["Cary FitzHugh", "Steve Signell"],
                  :climate_changes=>["root", "root2::", "root2::leaf"],
                  :docid=>doc.docid,
                  :effects=>["root", "root2::", "root2::leaf"],
                  :content_types=>["document::", "document::report"],
                  :geofocuses => [Geofocus.first_or_create(name: "basin lake NY").id],
                  :image => "http:123",
                  :links=>["pdf::http://google.com/pdf", "weblink::http://google.com/weblink"],
                  :keywords=>["danger"],
                  :pubend=>to_cs_date(date),
                  :publishers=>["NOAA"],
                  :pubstart=>to_cs_date(date),
                  :sectors=>["root", "root2::", "root2::leaf"],
                  :states=>["VT", "MA", "CT"],
                  :strategies=>["adaptation"],
                  :subtitle => "Subtitle!",
                  :title=>"Title"}

    doc_result = doc.to_search_document
    # remove thes earch terms, it's a grab bag of text..
    doc_result.delete(:search_terms)
    assert_equal doc_expected, doc_result
  end

  def test_filter_query
    assert_equal "(and (or 1 2 3))", to_filter_query([:and, [:or, 1, 2, 3]])
  end

  def test_geofocus_search
    geofocus = Geofocus.create(name: "Test")
    doc = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      content_types: ["format::1"],
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    )
    doc.sync_index!

    # GF Doc 2 - has same fields but different GF
    geofocus2 = Geofocus.create(name: "Test@")
    doc2 = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      content_types: ["format::1"],
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus2.id],
    )

    # GF Doc 3 - has same fields but no GF
    doc2 = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      content_types: ["format::1"],
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [],
    )

    wait_for_cs_sync!

    # Now we make a few searches
    results = Resource.search(geofocuses: [])
    assert_equal 3, results.hits.found

    results = Resource.search(geofocuses: [geofocus.id])
    assert_equal 1, results.hits.found

    results = Resource.search(geofocuses: [geofocus2.id])
    assert_equal 1, results.hits.found
  end
end
