require 'test_helper'

class FeedbackTest < NDSTestBase
  def test_crud
    assert Feedback.create(name: "George",
                            organization: "Jungle",
                            email: "george@thejungle.com",
                            phone: '777-111-2222',
                            comment: "We really like the jungle.  Strong as he can be",
                            contact: false)
    assert Feedback.create(

                            email: "george@thejungle.com",
                            contact: false)
  end
end
