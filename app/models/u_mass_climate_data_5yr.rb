#   CREATE UNIQUE INDEX unique_data_values ON ma.climate_data_raw_2019_5yr (year, variable_name, season, scenario, area_type, area_name);
#          Table "ma.climate_data_raw_2019_5yr"
#     Column     |          Type          | Modifiers
# ---------------+------------------------+-----------
#  year          | integer                |
#  variable_name | character varying(32)  |
#  season        | character varying(32)  |
#  scenario      | character varying(10)  |
#  min           | double precision       |
#  med           | double precision       |
#  max           | double precision       |
#  area_type     | character varying(255) |
#  area_name     | character varying(255) |
# Indexes:
#     "unique_data_values" UNIQUE, btree (year, variable_name, season, scenario, area_type, area_name)

require 'dm-postgis'
require 'georuby'
require 'geo_ruby/geojson'

class UMassClimateData5yr
  include DataMapper::Resource
  def self.default_repository_name
    :geoserver
  end

  property :year, Integer
  property :variable_name, String
  property :season, String
  property :scenario, String
  property :min, Float
  property :med, Float
  property :max, Float
  property :area_type, String
  property :area_name, String

  def self.get(area_type, season, variable_name)
    # (ma always I guess)
    # area (basin, county, state?)
    # season (annual, spring, summer, fall, etc)
    # type (avgtemp, days_gt_100, etc...)

    adapter = DataMapper.repository(:geoserver).adapter
    fields = ['year', 'variable_name', 'season', 'scenario',
              'min', 'med', 'max',
              'area_type',
              'area_name']
    sql = "select #{fields.join(',')} from ma.climate_data_raw_2019_5yr"
    wheres = []
    vars = []

    wheres.push("season = ?")
    vars.push(season)
    wheres.push("area_type = ?")
    vars.push(area_type)
    wheres.push("variable_name = ?")
    vars.push(variable_name)

    sql += ' WHERE ' + wheres.join(" AND ")

    adapter.select(sql, *vars)
  end
end
