#!/usr/bin/env ruby
require 'inquirer'
require 'cgi'
require 'net/http'
require 'json'
require 'colorize'
require 'cgi'
require 'pp'
require 'mechanize'
require 'aws-sdk'
require 'pry'
require 'digest'
BUCKETNAME='nescaum-dataservices-assets'

host = "http://localhost:4000" #Ask.input "API Host"
username = "cfitzhugh" #Ask.input "Username"
password = "password" #Ask.input("Password", password: true)

def image_url(host, url)
  if url
    key = Digest::MD5.hexdigest(url)
    obj = Aws::S3::Object.new(
      bucket_name: BUCKETNAME,
      key: "uploaded_image/#{URI.parse(host).hostname}/#{key}"
    )
    if obj.exists?
      obj.public_url(virtual_host: true)
    else
      ## Download it from the nyclimatescience.org site
      ## Put it in the S3 bucket
      #resp = s3.put_object(
      #  :bucket => "mybucket",
      #  :key => "myfolder/upload_me.sql",
      #  :body => "./upload_me.sql"
      #)
      # Download the image, upload to .... somewhere (S3?)
      # Get the URL
      #
    end
  end
  nil
end

def resource_present?(host, data)
  res_id = to_id(data)
  uri = URI.parse("#{host}/resources/internal/#{CGI.escape(res_id)}")
  resp = JSON.parse(Net::HTTP.get(uri))
  resp['code'] != 404
end

def to_id(data)
  url = data['resource']
  url.split("/").last
end

def pubdate(data)
  if (data['publicationdate'])
    data['publicationdate'].split("T")[0]
  else
    nil
  end
end

def fociandabstracts
  if !@fociandabstracts
    loaded = JSON.parse(File.read("./vivo/fociandabstracts.json"))
    @fociandabstracts = {}
    loaded.each do |entry|
      id = to_id(entry)
      @fociandabstracts[id] ||= {geofocuses: [] }
      @fociandabstracts[id][:abstract] = entry['abstract'] if entry['abstract']
      @fociandabstracts[id][:geofocuses].push(entry['geographicFocus']) if entry['geographicFocus']
    end
  end
  @fociandabstracts
end

def get_geofocuses(data)
  id = to_id(data)
  (fociandabstracts[id] || {})[:geofocuses] || []
end

def get_abstract(data)
  id = to_id(data)
  (fociandabstracts[id] || {})[:abstract]
end

def lookup_geofocus(host, name)
  uri = URI.parse("#{host}/geofocuses/?q=#{name}")
  resp = Net::HTTP.get(uri)
  JSON.parse(resp)['geofocuses'][0]
end

def geofocuses(host, data)

  get_geofocuses(data).map do |name|
    # Using the API, find the geofocus
    # If not found, create a geofocus with that new name? (ask first?)
    # Can try to correlate?
    gf = lookup_geofocus(host, name)
    if gf
      gf['id']
    else
      puts 'Could not find geofocus...'
      nil
    end
  end.compact
  []
end



def create_resource(host,cookie, data)
  uri = URI.parse("#{host}/resources")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = uri.scheme == 'https'
  req = Net::HTTP::Post.new(uri.path,
        initheader = {'Content-Type' => 'application/json',
                      'Cookie' => cookie.to_s,
                      'Accept' => 'application/json'})

  resource = {
    :title => data['title'],
    :subtitle => data['subtitle'],
    :image => image_url(host, data['imageURL']),
    :content => get_abstract(data),
    :external_data_links => data['links'].map do |link|
      "#{link['linklabel']}::#{link['link']}"
    end,
    :published_on_start => pubdate(data),
    :published_on_end => pubdate(data),
    :geofocuses => geofocuses(host, data),
    :actions => data['actions'] || [],
    :authors => data['authors'] || [],
    :internal_id => to_id(data),
    :climate_changes => data['climatechanges'] || [],
    :content_types => ["#{data['format'].capitalize}::#{data['type']}"],
    :keywords => data['keywords'],
    :publishers => data['publishers'],
    :sectors => data['sectors'],
    :strategies => data['strategies'],
    :states => []
  }

  req.body = JSON.generate({'resource' => resource })
  https.request(req)
end

cookie = ''
a = Mechanize.new
a.get("#{host}") do |page|
  login_page = a.click(page.link_with(:text => /Login/))

  mypage = login_page.form_with(:action => "/sign_in") do |f|
    f.field_with(:name => "username") do |uname_field|
      uname_field.value = username
    end
    f.field_with(:name => "password") do |pword_field|
      pword_field.value = password
    end
  end.submit

  cookie = a.cookie_jar.jar[URI.parse(host).hostname]['/']['rack.session']

  file_to_import = "vivo/dataresources.json" #Ask.input "Resources File to load"

  data_file = JSON.parse(File.read(file_to_import))
  data_file.each do |data|
    if (resource_present?(host, data))
      #puts "Prob#ably already exists".yellow
    else
      create_result = create_resource(host, cookie, data)
      if create_result.is_a? Net::HTTPOK
        puts "Created #{data['title']}".green
      else
        puts "Failed to create #{data['title']}".red
      end
    end
  end
end
#sign_in_page = Net::HTTP.get(host, '/sign_in')
#puts sign_in_page
