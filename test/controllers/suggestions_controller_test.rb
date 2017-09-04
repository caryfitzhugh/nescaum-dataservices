require 'test_helper'

class SuggestionControllerTest < NDSTestBase
  def test_creation
    post_json "/suggestions", {"suggestion" => {name: "George",
                                           organization: "Jungle",
                                           phone: '123-456-7890',
                                           email: "george@thejungle.org",
                                           title: "Title",
                                           description: "Descr",
    type: "PDF",
    href: "http://123.com",
    source: "Google",
    sectors: ['1','2','3'],
    keywords: "a b c"}}

    assert response.ok?
    assert_equal 1, Suggestion.count
  end

  def test_get
    fb = get_suggestion
    get "/suggestions/#{fb.id}"

    assert !response.ok?

    login_curator!
    get "/suggestions/#{fb.id}"

    assert response.ok?
  end

  def get_suggestion
    fb = Suggestion.new(name: "George",
                            organization: "Jungle",
                            email: "george@thejungle.com",
                            phone: '777-111-2222',
                            title:" Title",
                            description: "Description",
                            type: "PDF",
                            href: "HREF",
                            source: "Google",
                            sectors: ['1','2'],
                            keywords: "ABC")
    assert fb.save
    fb
  end
end
