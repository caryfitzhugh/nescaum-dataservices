require 'test_helper'

class SuggestionTest < NDSTestBase
  def test_crud
    assert Suggestion.create(name: "George",
                             email: "george@thejungle.com",
                            organization: "Jungle",
                            phone: '777-111-2222',
                            title: "OftHeJuNgLe",
                            description: "We really like the jungle.  Strong as he can be",
                            type: "piddle",
                            href: "http://google.com",
                            source: "Google",
                            sectors: ["a","b","c"],
                            keywords: "a really great list of keywords and things")
  end
end
