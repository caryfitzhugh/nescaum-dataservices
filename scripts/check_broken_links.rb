require './nds_app'

require 'net/http'
require 'uri'

def valid_path?(path, allowed_redirects=5)
  allowed_redirects.times do
    url = URI.parse(path)
    begin
      response = Net::HTTP.new(url.host, url.port).request_head(url.path)

      if response.kind_of?(Net::HTTPRedirection)
        path = response['location']
      else
        return response.kind_of?(Net::HTTPSuccess)
      end
    rescue
      ## Do nothing
    end
  end

  false
end

Resource.all(indexed: true).each_chunk(100) do |chunk|
  chunk.each do |resource|
    resource.external_data_links.each do |edl|
      url = edl.split("::", 2)[1]
      if !valid_path?(url)
        puts resource.id
      end
    end
  end
end
