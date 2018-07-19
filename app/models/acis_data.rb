require 'dm-postgis'
require 'georuby'
require 'geo_ruby/geojson'

class AcisData
  include DataMapper::Resource
  def self.default_repository_name
    :geoserver
  end

  # https://adirondackatlas.org/api/v1/ny_climatedeltas.php?parameter=avgt&geojson=true
  # https://adirondackatlas.org/api/v1/ny_climateobs.php?parameter=avgt&geojson=true
  #
  property :geomtype, String
  property :uid, String
  property :variable_name, String
  property :geom, PostGISGeometry
  property :data, Json

  def self.ny_observed(variable_name, include_geojson, geomtype)
      require 'pry'
      binding.pry

      adapter = DataMapper.repository(:geoserver).adapter
      sql = 'select * from ny.acis_observed'
      wheres = []
      vars = []

      if geomtype
        wheres.push('geomtype = ?')
        vars.push(geomtype)
      end

      wheres.push("variable_name = ?")
      vars.push(variable_name)

      sql += ' WHERE ' + wheres.join(" AND ")

      adapter.select(sql, *vars).each do |res|
        #  You need to run this on the staging server, and connect to the DB
        #  And do these queries, and make them come back with GeoJSON data
        #  woot woot.
        results.push({ county: res.name,
          state: 'ma',
          year: res.year.to_i,
          variable: res.variable_name,
          season: res.season,
          uid: res.uid,
          data: {
            high: res.range.split(" to ")[1].to_f,
            low: res.range.split(" to ")[0].to_f,
            baseline: res.baseline.to_f,
            average: res.avg.to_f
          }
        })
      end
      #  #<struct geomtype="state", name="MA", uid="25", variable_name="templt32", year="2050",
        #   season="spring", baseline="37.24",
        #   avg=#<BigDecimal:55d60462e078,'-0.1018E2',18(18)>,
        #   range="-6.4 to -14.9">
      results
  end
end
end
