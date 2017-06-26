require 'test_helper'

class ResourceTest < NDSTestBase
  # /home/cfitzhugh/.rvm/gems/ruby-2.3.4@nescaum-dataservices/gems/aws-sdk-core-2.9.25/lib/aws-sdk-core/plugins/request_signer.rb : 89
  def test_geofocus
    doc = Resource.new
    doc.content = "### Abstract"
    doc.authors = ["Cary FitzHugh", "Steve Signell"]
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.formats = ["document::report"]
    doc.published_on_start = Date.today
    doc.published_on_end = Date.today
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.save!

    doc.to_search_document
    doc.sync_index!
  end

  def test_cs_update
    doc = Resource.new
    doc.content = "### Abstract"
    doc.authors = ["Cary FitzHugh", "Steve Signell"]
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.formats = ["document::report"]
    doc.published_on_start = Date.today
    doc.published_on_end = Date.today
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.save!

    doc.sync_index!
    wait_for_cs_sync!

    results = Resource.search()
    assert_equal results.hits.found, 0

    doc.indexed = true
    doc.save!
    doc.sync_index!

    wait_for_cs_sync!
    results = Resource.search()
    assert_equal results.hits.found, 1
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
    doc.formats = ["document::report"]
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.external_data_links = [
      "pdf::http://google.com/pdf",
      "weblink::http://google.com/weblink",
    ]
    doc.publishers = ["NOAA"]
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
                  :docid=>"resource::1",
                  :effects=>["root", "root2::", "root2::leaf"],
                  :formats=>["document::", "document::report"],
                  :geofocus => ["basin lake NY"],
                  :image => "",
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
end
