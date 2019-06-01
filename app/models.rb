require 'data_mapper'
require 'dm-postgres-types'
require 'dm-postgis'
require 'dm-chunked_query'
require 'dm-timestamps'

require 'app/models/acis_data'
require 'app/models/geofocus'
require 'app/models/geofocus_resource'
require 'app/models/u_mass_climate_data_5yr'
require 'app/models/u_mass_climate_data_30yr'
require 'app/models/resource_action'
require 'app/models/resource_action_link'
require 'app/models/resource_author'
require 'app/models/resource_author_link'
require 'app/models/resource_climate_change'
require 'app/models/resource_climate_change_link'
require 'app/models/resource_effect'
require 'app/models/resource_effect_link'
require 'app/models/resource_keyword'
require 'app/models/resource_keyword_link'
require 'app/models/resource_publisher'
require 'app/models/resource_publisher_link'
require 'app/models/resource_content_type'
require 'app/models/resource_content_type_link'
require 'app/models/resource_sector'
require 'app/models/resource_sector_link'
require 'app/models/resource_strategy'
require 'app/models/resource_strategy_link'
require 'app/models/resource_state'
require 'app/models/resource_state_link'

require 'app/models/ma/action_track_action'
require 'app/models/ma/action_track_agency_priority'
require 'app/models/ma/action_track_benefit'
require 'app/models/ma/action_track_exec_office'
require 'app/models/ma/action_track_hazard'
require 'app/models/ma/action_track_lead_agency'
require 'app/models/ma/action_track_partner'
require 'app/models/ma/action_track_primary_climate_interactions'
require 'app/models/ma/action_track_sector'
require 'app/models/ma/action_track_shmcap_goal'
require 'app/models/ma/action_track'

require 'app/models/action'
require 'app/models/climate_data'
require 'app/models/collection'
require 'app/models/feedback'
require 'app/models/resource'
require 'app/models/suggestion'
require 'app/models/user'
require 'app/models/map_state'

require 'lib/config'

DataMapper.finalize

DataMapper::Logger.new($stdout, :info)
if CONFIG.postgres
  connected = false
  while !connected
    begin
      DataMapper.setup(:default, CONFIG.postgres.to_h)
      connected = true
    rescue DataObjects::ConnectionError
      connected = false
      sleep 1
    end
  end
else
  raise "Need to have POSTGRES_DB_URL set!"
end

if CONFIG.postgres_geoserver
  connected = false
  while !connected
    begin
      DataMapper.setup(:geoserver, CONFIG.postgres_geoserver.to_h)
      connected = true
    rescue DataObjects::ConnectionError
      connected = false
      sleep 1
    end
  end
else
  puts "Need to have GEOSERVER_POSTGRES ENV set!"
end
