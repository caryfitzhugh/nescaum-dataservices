require 'test_helper'

class MapStateTest < NDSTestBase
  def test_crud
    ms = MapState.new(:data => "ABC")
    assert !ms.token
    ms.generate_token!
    assert ms.token

    assert ms.save

    ms2 = MapState.first(:token => ms.token)
    assert_equal ms2.data, ms.data
  end
end
