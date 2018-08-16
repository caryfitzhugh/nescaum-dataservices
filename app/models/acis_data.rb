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
  property :geomtype, String
  property :uid, String, :key => true
  property :variable_name, String
  property :geom, PostGISGeometry
  property :data, String
  property :name, String

  def self.ny_observed(variable_name, include_geojson, geomtype)
      #require 'pry'
      #binding.pry

      adapter = DataMapper.repository(:geoserver).adapter
      fields = ['geomtype','uid','variable_name','data', 'name']
      if include_geojson
        fields << 'ST_AsGeoJSON(geom) as geom'
      end
      sql = "select #{fields.join(',')} from ny.acis_observed"
      wheres = []
      vars = []

      if geomtype
        wheres.push('geomtype = ?')
        vars.push(geomtype)
      end

      wheres.push("variable_name = ?")
      vars.push(variable_name)

      sql += ' WHERE ' + wheres.join(" AND ")

      adapter.select(sql, *vars).map do |res|
        result = { geomtype: res.geomtype,
          name: res.name,
          variable_name: res.variable_name,
          uid: res.uid,
          data: JSON.parse(res.data).map {|datum|
                {season: datum['season'],
                 values: datum['values'].map {|value|
                                { year: value['year'].to_i,
                                  data_value: value['data_value'].to_f}
                        }
                }
          }
        }

        if include_geojson
          result[:geom] = JSON.parse(res.geom)
        end
        result
      end
      #  #<struct geomtype="state", name="MA", uid="25", variable_name="templt32", year="2050",
        #   season="spring", baseline="37.24",
        #   avg=#<BigDecimal:55d60462e078,'-0.1018E2',18(18)>,
        #   range="-6.4 to -14.9">
  end
end
