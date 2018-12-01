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

      # Find all the broken links and use a cache to keep track of things that were already looked up
      send_broken_resources_email(resources)

      json({
        msg: "Found ${broken_resources.length} broken resources. Email sent"
      })
    end
  end
end
