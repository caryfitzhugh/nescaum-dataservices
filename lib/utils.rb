require 'ostruct'
require 'net/http'
require 'uri'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  options = {
    debug: true,
    js_errors: false,
    timeout: 30,
    window_size: [1280, 1440],
    # port: 44678+ENV['TEST_ENV_NUMBER'].to_i,
    phantomjs_option: [
      '--proxy-type=none',
      '--load-images=no',
      '--ignore-ssl-errors=yes',
      '--ssl-protocol=any',
      '--web-security=false',
      '--debug=true'
    ]
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false
Capybara.default_max_wait_time = 30

def capybara_session(reset=false)
  session = Capybara.current_session
  Capybara.current_session.driver.add_header('User-Agent',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36')
  begin
    yield session
  rescue Exception => e
    puts(e)
  ensure
    Capybara.reset_sessions!
  end
end

def check_url!(url, allowed_redirects=5)
   puts "Checking on #{url} url..."
   res = false
   begin
      res = check_url_without_browser!(url) or check_url_with_phantomjs!(url)
   ensure
      puts "#{url} => #{res}"
   end
   STDOUT.flush
   res
end

def check_url_with_phantomjs!(url, allowed_redirects=5)
  puts("check w/ browser")
  result = false
  begin
    capybara_session() do |session|
      session.visit(url)
      result = session.status_code == 200
    end
  rescue Exception => e
      puts "Error"
      puts e
      result = false
  end
  result
end

def check_url_without_browser!(uri, allowed_redirects=20)
  puts("check w/o browser")
  begin
    url = URI.parse(uri)

    allowed_redirects.times do
      Net::HTTP.start(url.host, url.port,
                      :read_timeout => 15,
                      :open_timeout => 15,
                      :use_ssl => (url.scheme == "https")) do |http|

        path = url.path
        if path == ''
            path = "/"
        end
        response = http.request_get path # Net::HTTPResponse object

        if response.kind_of?(Net::HTTPRedirection)
          url.merge(URI.parse(response['location']))
        else
          return response.kind_of?(Net::HTTPSuccess)
        end
      end
    end
  rescue URI::InvalidURIError
    puts "Invalid URI: " + uri
    false
  rescue Net::ReadTimeout, Net::OpenTimeout
    puts "Read timeout expired: " + uri
    # ReadTimeout .. but
    false
  rescue SocketError
    puts "socket error: " + uri
    false
  rescue Exception => e
    puts "error: " + uri
    puts e.backtrace
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
