require 'test_helper'

class ResourcesControllerTest < NDSTestBase
  def test_crud_resource
    login_curator!
    post "/", JSON.generate({"resource" => { }})
  end
end
