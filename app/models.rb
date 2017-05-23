require 'app/models/resource'
require 'lib/config'
DataMapper.finalize

DataMapper::Logger.new($stdout, :debug)

if CONFIG.postgres
  puts ENV
  puts CONFIG.postgres
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
