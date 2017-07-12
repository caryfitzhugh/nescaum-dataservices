require 'test_helper'

class ActionTest < NDSTestBase
  def test_find_with_at
    user = User.create!(username: 'user', password: 'password')
    at = Time.now - 7 # 1 week ago
    old_action = Action.new(table: "foo", record_id: 1, user_id: user.id, description: "created", at: at)
    assert old_action.save

    at = DateTime.now + 7 # 1 week in future
    new_action = Action.new(table: "foo", record_id: 1, user_id: user.id, description: "created", at: at)
    assert new_action.save

    assert_equal [old_action], Action.all(:at.lte => Time.now)
    assert_equal [new_action], Action.all(:at.gte => Time.now)
  end
end
