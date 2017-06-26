require 'test_helper'

class GeofocusTest < NDSTestBase
  def test_creation_duplicate
    assert_nothing_thrown do
      Geofocus.create!(name: "HI")
    end
    assert_raise do
      Geofocus.create!(name: "HI")
    end
  end
end
