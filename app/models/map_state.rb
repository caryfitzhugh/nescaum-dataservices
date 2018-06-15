require 'digest'
require 'dm-postgis'

class MapState
  include DataMapper::Resource
  property :data, String
  property :token, String, :key => true

  def generate_token!
    attribute_set(:token, Digest::MD5.hexdigest(self.data))
  end

  def to_resource
     {'data': self.data }
  end

end
