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
          wheres.push('name IN ?')
          vars.push(counties)
        end

        unless years.empty?
          wheres.push('year in ?')
          vars.push(years.map(&:to_s))
        end

        unless seasons.empty?
          wheres.push('season in ?')
          vars.push(seasons)
        end

        unless variables.empty?
          wheres.push('variable_name in ?')
          vars.push(variables)
        end

        unless wheres.empty?
          sql += ' WHERE ' + wheres.join(" AND ")
        end

        adapter.select(sql, vals).each do |res|
          results.push({ county: res.name,
            state: 'ma',
            year: res.year.to_i,
            variable: res.variable_name,
            data: {
              high: res.range.split(" to ")[1].to_f,
              low: res.range.split(" to ")[0].to_f,
              baseline: res.baseline.to_f,
              average: res.avg.to_f
            }
          })
        end
      else

      end
      #  #<struct geomtype="state", name="MA", uid="25", variable_name="templt32", year="2050",
        #   season="spring", baseline="37.24",
        #   avg=#<BigDecimal:55d60462e078,'-0.1018E2',18(18)>,
        #   range="-6.4 to -14.9">
      results
  end
end
