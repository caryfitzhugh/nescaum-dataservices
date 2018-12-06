require 'uri'
require 'net/http'
require 'selenium-webdriver'
require 'browsermob/proxy'

def with_proxy()
  server = BrowserMob::Proxy::Server.new('/opt/browsermob/browsermob-proxy-2.1.4/bin/browsermob-proxy', log: true)
  proxy = nil
  begin
    bmproxy = server.start.create_proxy
    profile = Selenium::WebDriver::Chrome::Profile.new
    proxy = Selenium::WebDriver::Proxy.new(:http => bmproxy.selenium_proxy.http)
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(:proxy => proxy)
    yield bmproxy, caps

  ensure
    if bmproxy
      bmproxy.close
    end
    if server
      server.stop
    end
  end
end

def with_browser()
    res = false
    driver = nil
    begin
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--disable-gpu')
      with_proxy() do |proxy, caps|
        driver = Selenium::WebDriver.for :chrome, options: options, desired_capabilities: caps
        yield driver, proxy
      end
    rescue Exception => e
      puts "error"
      puts e
    ensure
      driver.quit() if driver
    end
end

def check_url!(url, allowed_redirects=5)
   puts "Checking on #{url} url..."
   res = false
   begin
      res = check_url_without_browser!(url, allowed_redirects: allowed_redirects) or check_url_with_browser!(url)
   ensure
      puts "#{url} => #{res}"
   end
   STDOUT.flush
   res
end

def check_url_with_browser!(url)
  puts("check w/ browser")
  result = false
  begin
    with_browser() do |browser, proxy|
      proxy.new_har
      browser.get(url)

      puts browser.title
      puts proxy.har.entries.first.response.status

      # If there is no title
      # of the response is 404
      is404 = browser.title.empty? ||
              browser.title =~ /404/ ||
              browser.title =~ /Not Found/i ||
              proxy.har.entries.first.response.status == 404

      result = !is404
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
          url = url.merge(URI.parse(response['location']))
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
