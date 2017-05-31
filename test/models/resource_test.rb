require 'test_helper'

class ResourceTest < NDSTestBase
  def test_expand_literal
    [
      [['ok'], 'ok'],
      [['ok::','ok::too'], 'ok::too'],
      [['ok::','ok::too::', 'ok::too::three'], 'ok::too::three'],
    ].each do |desired, input|
      assert_equal desired, Models::Resource.send(:expand_literal, input)
    end
  end

  def test_to_resource_def
    date = Date.today
    doc = Models::Resource.new
    doc.content = "### Abstract"
    doc.authors = ["Cary FitzHugh", "Steve Signell"]
    doc.title = "Title"
    doc.format = "document::report"
    doc.geofocus = ["basin lake NY"]
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
                  :docid=>"models::resource::1",
                  :effects=>["root", "root2::", "root2::leaf"],
                  :formats=>["document::", "document::report"],
                  :geofocus => ["basin lake NY"],
                  :links=>["pdf::http://google.com/pdf", "weblink::http://google.com/weblink"],
                  :keywords=>["danger"],
                  :pubend=>to_cs_date(date),
                  :publishers=>["NOAA"],
                  :pubstart=>to_cs_date(date),
                  :sectors=>["root", "root2::", "root2::leaf"],
                  :states=>["VT", "MA", "CT"],
                  :strategies=>["adaptation"],
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
