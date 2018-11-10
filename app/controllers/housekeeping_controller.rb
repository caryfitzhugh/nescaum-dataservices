require 'app/controllers/base'
require 'app/models'

module Controllers
  class HousekeepingController < Controllers::Base

    type 'HousekeepingMissingLinksResponse', {
      properties: {
        msg: { type: String, description: "Response string"},
      }
    }

    endpoint description: "Run missing link checks",
              responses: standard_errors( 200 => "HousekeepingMissingLinksResponse"),
              parameters: { },
              tags: ["Housekeeping", "Public"]

    get "/acis/ny/observed/?" do
      resources = Resource.all

      link_cache = {}

      # Find all the broken links and use a cache to keep track of things that were already looked up
      broken_resources = resources.map do |r|
          [r, r.get_broken_links(link_cache: link_cache)]
      end.reject {|r| r[1].empty? }


      CONFIG.emails.broken_links.each do |to|
        send_alert_email(to, "#{broken_resources.length} Broken-Link Resources") do
          <<-EMAIL_BODY
            #{broken_resources.length} Resources Found with Broken Links
            #{broken_resources.map do |r|
              "#{r[0].id} #{r[0].title} - #{r[1].join("\n  * ")}"
            end.join "\n"}
          EMAIL_BODY
        end

      json({
        msg: "Found ${broken_resources.length} broken resources. Email sent"
      })
    end

    type 'AcisProjectedDataFeaturePropertyValue', {
      properties: {
        year: { type: Integer, description: "Year"},
        delta_low: { type: Float},
        delta_high: { type: Float},
      }
    }

    type 'AcisProjectedDataFeaturePropertyDetail', {
      properties: {
        season: { type: String, description: "Season"},
        values: { type: ["AcisProjectedDataFeaturePropertyValue"]},
      }
    }

    type 'AcisProjectedDataFeatureProperties', {
      properties: {
        variable_name: { type: String, description: "Variable of data: " + [
                    'mint',
                    'maxt',
                    'maxt_gt_95',
                    'mint_lt_32',
                    'avgt',
                    'gdd',
                    'hdd',
                    'maxt_gt_90',
                    'pcpn_gt_2',
                    'maxt_gt_100',
                    'mint_lt_0',
                    'pcpn_gt_1',
                    'cdd',
                    'pcpn'].to_json},
        geomtype: { type: String, description: "Geometry type [basin, county]"},
        name: { type: String, description: "Data description"},
        uid: { type: String, description: "UID of data location"},
        data: { type: ['AcisProjectedDataFeaturePropertyDetail'], description: "The Data"}
      }
    }

    type 'AcisProjectedDataFeature', {
      properties: {
        type: { type: String, description: "type of feature"},
        geometry: { type: String, description: "Geojson of the feature"},
        properties: { type: "AcisProjectedDataFeatureProperties"},
      }
    }

    type 'AcisProjectedDataGeoJSON', {
      properties: {
        type: { type: String, description: "Type of GeoJSON"},
        features: { type: ["AcisProjectedDataFeature"], description: "Features"}
      }
    }

    endpoint description: "Get Projected ACIS Data",
              responses: standard_errors( 200 => "AcisProjectedDataGeoJSON"),
              parameters: {
                "variable_name"  => ["Parameter to return (mint, maxt, etc.)", :query, false, String],
                "geomtype"  => ["Geometry type to return (basin/county)", :query, false, String],
                "geojson"  => ["GeoJson should be included flag", :query, false, String],
              },
              tags: ["ACIS", "Climate Data", "Public"]

    get "/acis/ny/projected/?" do
      cross_origin

      features = AcisData.ny_projected(params['variable_name'],
                                      params['geojson'] =~ /true/i,
                                      params['geomtype'])
      json({
        "type": "FeatureCollection",
        "features": features
      })
    end
  end
end
