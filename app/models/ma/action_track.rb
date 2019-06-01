require 'dm-postgis'

class MA::ActionTrack
  include DataMapper::Resource

  # Action title: unique name
  property :title, String, :unique => true
  # Action description: unique description
  property :description, String
  # Executive Office - drop down
  has 1, :action_track_exec_office, "MA::ActionTrackExecOffice"
  # Lead Agency - drop down
  has 1, :action_track_lead_agency, "MA::ActionTrackLeadAgency"
  # Partner(s) - unique fill ahead
  has n, :action_track_partner, "MA::ActionTrackPartner"
  # Agency Priority Score - drop down
  has 1, :action_track_agency_priority, "MA::ActionTrackPriority"
  # Possible Funding Source(s) - unique - fill ahead
  has n, :action_track_funding_source, "MA::ActionTrackFundingSource"
  # SHMCAP Goal(s) - drop down
  has n, :action_track_shmcap_goal, "MA::ActionTrackShmcapGoal"
  # Primary Climate Change Interactions - drop down
  has n, :action_track_primary_climate_interactions
  # Completion Timeframe - unique - month/year -need start and end
  property :start_on, Date
  property :end_on, Date

  # Hazards - TBD
  has n, :action_track_hazard
  # Sectors - TBD
  has n, :action_track_sector
  # Actions - TBD
  has n, :action_track_action
  # Benefits - TBD
  has n, :action_track_benefit
end
