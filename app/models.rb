require 'data_mapper'
require 'dm-postgres-types'
require 'dm-chunked_query'
require 'dm-timestamps'

require 'app/models/geofocus'
require 'app/models/geofocus_resource'
require 'app/models/resource'
require 'app/models/user'
require 'app/models/collection'
require 'app/models/action'

require 'lib/config'

DataMapper.finalize

DataMapper::Logger.new($stdout, :info)

if CONFIG.postgres
  connected = false
  while !connected
    begin
      DataMapper.setup(:default, CONFIG.postgres)
      connected = true
    rescue DataObjects::ConnectionError => e
      connected = false
      sleep 1
    end
  end
else
  raise "Need to have POSTGRES_DB_URL set!"
end
