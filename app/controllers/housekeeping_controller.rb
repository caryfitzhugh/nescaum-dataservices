require 'app/controllers/base'
require 'app/models'
require 'lib/email'

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
              tags: ["Housekeeping", "Curator"]

    #get "/housekeeping/broken-link-checks/?", require_role: :curator do
    get "/housekeeping/broken-link-checks/?" do
      resources = Resource.all

      link_cache = {}

      # Find all the broken links and use a cache to keep track of things that were already looked up
      broken_resources = resources.map do |r|
          [r, r.get_broken_links(link_cache: link_cache)]
      end.reject {|r| r[1].empty? }


      CONFIG.emails.broken_links.each do |to|
        send_alert_email(to, "#{broken_resources.length} Broken-Link Resources") do
          <<-EMAIL_BODY
            <h2>#{broken_resources.length} Resources Found with Broken Links</h2>
            <ul>
            #{broken_resources.map do |r|
              "<li>#{r[0].id} #{r[0].title} - <ul>#{r[1].map {|l| "<li>#{l}</li>")}}</ul> </li>"
            end}
            </ul>
          EMAIL_BODY
        end
      end

      json({
        msg: "Found ${broken_resources.length} broken resources. Email sent"
      })
    end
  end
end
