require 'test_helper'

class HomeCurationControllerTest < NDSTestBase
  def test_it_works
    login_curator!
    visit Paths.curation_home_path
  end
  def test_it_requires_curator
    visit Paths.curation_home_path
    assert_equal last_response.status, 403
  end
end
