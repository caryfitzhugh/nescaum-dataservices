class User
  ROLES= ["admin", "curator"]

  include DataMapper::Resource

  property :id, Serial
  property :username, String, required: true, unique: true
  property :email, String
  property :name, String
  property :password, BCryptHash, required: true
  property :roles, PgArray

  def is_admin?
    self.roles.any? {|r| r == "admin"}
  end
  def is_curator?
    is_admin? || self.roles.any? {|r| r == "curator"}
  end
end
