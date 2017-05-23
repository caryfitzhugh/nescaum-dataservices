require 'app/models/resource'
require 'lib/config'
DataMapper.finalize

DataMapper::Logger.new($stdout, :debug)

if CONFIG.postgres
  connected = false
  while !connected
    begin
      args = {
        adapter: "postgres",
        database: ENV['RDS_DB_NAME'],
        username: ENV['RDS_USERNAME'],
        password: ENV['RDS_PASSWORD'],
        host: ENV["RDS_HOSTNAME"]
      }
      DataMapper.setup(:default, CONFIG.postgres)
      #DataMapper.setup(:default, args )
      connected = true
    rescue DataObjects::ConnectionError => e
      connected = false
      sleep 1
    end
  end
else
  raise "Need to have POSTGRES_DB_URL set!"
end
