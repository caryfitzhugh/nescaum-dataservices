require 'test_helper'

class FeedbackControllerTest < NDSTestBase
  def test_creation
    post_json "/feedback", {"feedback" => {name: "George",
                                           organization: "Jungle",
                                           comment: "Good grief",
                                           contact: 'false',
                                           phone: '123-456-7890',
                                           email: "george@thejungle.org"}}
    assert response.ok?
    assert_equal 1, Feedback.count

    post_json "/feedback", {"feedback" => {name: "George",
                                           organization: "Jungle",
                                           comment: "Good grief",
                                           contact: 'true',
                                           phone: '123-456-7890',
                                           email: "george@thejungle.org"}}
    assert response.ok?
    assert_equal 2, Feedback.count
    assert_equal true, Feedback.last.contact
  end

  def test_get
    fb = get_feedback
    get "/feedback/#{fb.id}"

    assert !response.ok?

    login_curator!
    get "/feedback/#{fb.id}"

    assert response.ok?
  end

  def get_feedback
    fb = Feedback.new(name: "George",
                            organization: "Jungle",
                            email: "george@thejungle.com",
                            phone: '777-111-2222',
                            comment: "We really like the jungle.  Strong as he can be",
                            contact: false)
    assert fb.save
    fb
  end
end
