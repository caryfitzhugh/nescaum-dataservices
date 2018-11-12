require 'ostruct'
require 'net/http'
require 'uri'

def check_url!(uri, allowed_redirects=5)
  puts "Checking on #{uri} url..."
  begin

    allowed_redirects.times do
      url = URI.parse(uri)

      Net::HTTP.start(url.host, url.port, :use_ssl => (url.scheme == "https")) do |http|
        request = Net::HTTP::Get.new url
        path = url.path
        if path == ''
            path = "/"
        end
        response = http.request_head path # Net::HTTPResponse object

        if response.kind_of?(Net::HTTPRedirection)
          uri = response['location']
        else
          return response.kind_of?(Net::HTTPSuccess)
        end
      end
    end
  rescue SocketError
    false
  end
  false
end

def to_recursive_ostruct(hash)
  OpenStruct.new(hash.each_with_object({}) do |(key, val), memo|
        memo[key] = val.is_a?(Hash) ? to_recursive_ostruct(val) : val
          end)
end

def to_cs_date(date)
  if date
    date.strftime("%Y-%m-%dT00:00:00.000Z")
  else
    nil
  end
end

# [:name [:next 1 2 3] [:other 1 2 3]]
def to_filter_query(arr)
  if arr.is_a? Array
    key = arr.shift
    "(#{key} " +
      arr.map {|sub| to_filter_query(sub)}.join(" ") +
    ")"
  else
    arr.to_s
  end
end
