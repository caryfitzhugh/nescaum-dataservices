require 'dm-postgis'
require 'georuby'
require 'geo_ruby/geojson'

class ClimateData
  include DataMapper::Resource
  def self.default_repository_name
    :geoserver
  end
  property :variable_name, String
  property :geomtype, String
  property :name, String, :key => true
  property :uid, String, :key => true
  property :season, String
  property :geom, PostGISGeometry
  property :data, Json

  def self.climate_delta_details(states: [], counties: [], years: [], seasons: [], variables: [])
      adapter = DataMapper.repository(:geoserver).adapter
      results = []
      if states.include?('ma')
        sql = 'select * from ma.climate_data_projected_parsed'
        wheres = []
        vars = []
        unless counties.empty?
          wheres.push('name IN (?)')
          vars.push(counties)
        end

        unless years.empty?
          wheres.push('year in (?)')
          vars.push(years)
        end

        unless seasons.empty?
          wheres.push('season in (?)')
          vars.push(seasons)
        end

        unless variables.empty?
          wheres.push('variable_name in (?)')
          vars.push(variables)
        end

        unless wheres.empty?
          sql += ' WHERE ' + wheres.join(" AND ")
        end

        results = results + adapter.select(sql, vars)
      else

      end
      results
  end
end
