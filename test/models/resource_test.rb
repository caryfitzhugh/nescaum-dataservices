require 'test_helper'

class ResourceTest < NDSTestBase
  def test_resource_delete
    date = Date.today
    doc = Resource.new
    doc.content = "### Abstract"
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.image  = "http:123"
    doc.external_data_links = [
      "pdf::http://google.com/pdf",
      "weblink::http://google.com/weblink",
    ]
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.published_on_start = date
    doc.published_on_end = date

    ["Cary FitzHugh", "Steve Signell"].each {|v| doc.resource_authors << ResourceAuthor.first_or_create(value: v)}
    ["document::report"].each {|v| doc.resource_content_types << ResourceContentType.first_or_create(value: v)}
    ["NOAA"].each {|v| doc.resource_publishers << ResourcePublisher.first_or_create(value: v)}
    ["danger"].each {|v| doc.resource_keywords << ResourceKeyword.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_sectors << ResourceSector.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_effects << ResourceEffect.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_actions << ResourceAction.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_climate_changes << ResourceClimateChange.first_or_create(value: v)}
    ["adaptation"].each {|v| doc.resource_strategies << ResourceStrategy.first_or_create(value: v)}
    ["VT", "MA", "CT"].each {|v| doc.resource_states << ResourceState.first_or_create(value: v)}

    assert doc.save, doc.errors.full_messages.join("\n")

    assert doc.destroy!
    assert_equal 2, ResourceAuthor.count
    assert_equal 1, ResourceContentType.count
    assert_equal 1, ResourceKeyword.count
    assert_equal 1, ResourcePublisher.count
    assert_equal 1, Geofocus.count
  end
  # /home/cfitzhugh/.rvm/gems/ruby-2.3.4@nescaum-dataservices/gems/aws-sdk-core-2.9.25/lib/aws-sdk-core/plugins/request_signer.rb : 89
  def test_geofocus
    doc = Resource.new
    doc.content = "### Abstract"
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.published_on_start = Date.today
    doc.published_on_end = Date.today
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")

    doc.save!
    # can we run this?
    doc.to_search_document
  end

  def test_resource_create
    doc = Resource.new
    doc.content = "### Abstract"
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.published_on_start = Date.today
    doc.published_on_end = Date.today
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")

    assert doc.save

    ResourceAction.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["hello"], doc.resource_actions.map(&:value)

    ResourceAuthor.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["Hello"], doc.resource_authors.map(&:value)

    ResourceClimateChange.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["hello"], doc.resource_climate_changes.map(&:value)

    ResourceEffect.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["hello"], doc.resource_effects.map(&:value)

    ResourceKeyword.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["hello"], doc.resource_keywords.map(&:value)

    ResourcePublisher.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["Hello"], doc.resource_publishers.map(&:value)

    ResourceContentType.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["Hello"], doc.resource_content_types.map(&:value)

    ResourceSector.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["hello"], doc.resource_sectors.map(&:value)

    ResourceStrategy.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["hello"], doc.resource_strategies.map(&:value)

    ResourceState.add_to_resource!(doc, "Hello")
    doc.reload

    assert_equal ["Hello"], doc.resource_states.map(&:value)
    # can we run this?
    doc.to_search_document
  end
  def test_cs_update
    doc = Resource.new
    doc.content = "### Abstract"
    ["Cary FitzHugh", "Steve Signell"].each {|v| doc.resource_authors << ResourceAuthor.first_or_create(value: v)}
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    ["document::report"].each {|v| doc.resource_content_types << ResourceContentType.first_or_create(value: v)}
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

  def test_search_geofocus_sort
    far_small = Geofocus.create(name:"Far - Small",
      geom: geom(:far_small))
    far_large = Geofocus.create(name:"Far - Large",
      geom: geom(:far_large))

    near_small = Geofocus.create(name:"Near - Small",
      geom: geom(:near_small))
    near_large = Geofocus.create(name:"Near - Large",
      geom: geom(:near_large))

    # Set up the records
    far_doc = geom_doc([far_small, far_large])
    near_doc = geom_doc([near_small, near_large])
    far_small_doc = geom_doc([far_small])
    far_large_doc = geom_doc([far_large])
    near_small_doc = geom_doc([near_small])
    near_large_doc = geom_doc([near_large])

    wait_for_cs_sync!

    results = Resource.search(bounding_box: [0,0,1,1])
    assert_equal results.hits.found, 6
    assert_equal [near_small_doc.docid], results.hits.hit[0].fields['docid']
    assert_equal [far_small_doc.docid], results.hits.hit[1].fields['docid']
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
    doc.title = "Title"
    doc.subtitle = "Subtitle!"
    doc.image  = "http:123"
    doc.external_data_links = [
      "pdf::http://google.com/pdf",
      "weblink::http://google.com/weblink",
    ]
    doc.geofocuses << Geofocus.first_or_create(name: "basin lake NY")
    doc.published_on_start = date
    doc.published_on_end = date

    ["Cary FitzHugh", "Steve Signell"].each {|v| doc.resource_authors << ResourceAuthor.first_or_create(value: v)}
    ["document::report"].each {|v| doc.resource_content_types << ResourceContentType.first_or_create(value: v)}
    ["NOAA"].each {|v| doc.resource_publishers << ResourcePublisher.first_or_create(value: v)}
    ["danger"].each {|v| doc.resource_keywords << ResourceKeyword.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_sectors << ResourceSector.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_effects << ResourceEffect.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_actions << ResourceAction.first_or_create(value: v)}
    ["root", "root2::leaf"].each {|v| doc.resource_climate_changes << ResourceClimateChange.first_or_create(value: v)}
    ["adaptation"].each {|v| doc.resource_strategies << ResourceStrategy.first_or_create(value: v)}
    ["VT", "MA", "CT"].each {|v| doc.resource_states << ResourceState.first_or_create(value: v)}

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
                  # No image in search doc :image => "http:123",
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
  def test_sector_search
    geofocus = Geofocus.create(name: "Test")
    doc = Resource.new(
      title: "S1",
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    )
    doc.resource_sectors << ResourceSector.create(value:"sector1")
    assert doc.save

    doc2 = Resource.new(
      title: "S2",
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    )
    doc2.resource_sectors << ResourceSector.create(value:"sector2")
    assert doc2.save

    doc3 = Resource.new(
      title: "S1,2",
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus.id],
    )
    doc3.resource_sectors << ResourceSector.first_or_create(value:"sector2")
    doc3.resource_sectors << ResourceSector.first_or_create(value:"sector1")
    assert doc3.save

    wait_for_cs_sync!

    results = Resource.search(filters: {sectors: ['sector1']});
    assert_equal 2, results.hits.found

    results = Resource.search(filters: {sectors: ['sector2']});
    assert_equal 2, results.hits.found

    results = Resource.search(filters: {sectors: ['sector2','sector1']});
    assert_equal 3, results.hits.found
  end

  def test_geofocus_search
    geofocus = Geofocus.create(name: "Test")
    doc = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
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
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: [geofocus2.id],
    )

    # GF Doc 3 - has same fields but no GF
    doc2 = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
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
  def test_searching
    doc = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      indexed: true,
      effects: ["facet1"],
      states: ["state1"],
    )
    doc.sync_index!

    # GF Doc 2 - has same fields but different GF
    doc2 = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      indexed: true,
      effects: ["facet1"],
      states: ["state2"],
    )

    # GF Doc 3 - has same fields but no GF
    doc2 = Resource.create!(
      title: "Title",
      subtitle: "Subtitle",
      indexed: true,
      effects: ["facet1"],
      states: ["state3"],
    )

    wait_for_cs_sync!

    # Now we make a few searches
    results = Resource.search(filters: {
      effects: ["facet1"]
    })
    assert_equal 3, results.hits.found

    results = Resource.search(filters: {
      effects: ["facet1"],
      states: ["state1"]
    })
    assert_equal 1, results.hits.found

    results = Resource.search(filters: {
      effects: ["facet1"],
      states: ["state1", "state2","state3"]
    })
    assert_equal 3, results.hits.found
  end
end
