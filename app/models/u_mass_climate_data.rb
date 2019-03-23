require 'dm-postgis'
require 'georuby'
require 'geo_ruby/geojson'

class UMassClimateData
  include DataMapper::Resource
  def self.default_repository_name
    :geoserver
  end

  property :geomtype, String
  property :uid, String, :key => true
  property :variable_name, String
  property :geom, PostGISGeometry
  property :data, String
  property :name, String

  def self.observed(variable_name, include_geojson, geomtype)
      raise "NotImplemented"
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
        result = {type: "Feature",
          geometry: nil,
          properties: {
                    geomtype: res.geomtype,
                    name: res.name,
                    variable_name: res.variable_name,
                    uid: res.uid,
                    data: JSON.parse(res.data).map {|datum|
                      {season: datum['season'].downcase,
                       values: datum['values'].map {|value|
                                      { year: value['year'].to_i,
                                        data_value: value['data_value'].to_f}}}}}}

        if include_geojson
          result[:geometry] = JSON.parse(res.geom)
        end
        result
      end
  end
    def self.projected(variable_name, include_geojson, geomtype)
      adapter = DataMapper.repository(:geoserver).adapter
      fields = ['geomtype','uid','variable_name','data', 'name']
      if include_geojson
        fields << 'ST_AsGeoJSON(geom) as geom'
      end
      sql = "select #{fields.join(',')} from ma.climate_projected_2019"
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
        data = {}

        JSON.parse(res.data).each do |datum|
          data[datum['season'].downcase] ||= {'season' => datum['season'].downcase, 'baseline' =>  datum['baseline'], 'values' => []}
          data[datum['season'].downcase]['values' ]+= (datum['values'].map do |value|
             { year: value['year'].to_i,
               range_low:  value['range_low'].split("to").map(&:to_f),
               range_high: value['range_high'].split("to").map(&:to_f),
               delta_low: value['delta_low'].to_f,
               delta_high: value['delta_high'].to_f}
          end)
        end

        result = {type: "Feature",
          geometry: nil,
          properties: {
            geomtype: res.geomtype,
            name: res.name,
            variable_name: res.variable_name,
            uid: res.uid,
            data: data.values
          }}

        if include_geojson
          result[:geometry] = JSON.parse(res.geom)
        end
        result
      end
  end
end
