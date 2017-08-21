#!/usr/bin/env ruby
require 'inquirer'
require 'cgi'
require 'net/http'
require 'json'
require 'colorize'
require 'cgi'
require 'pp'
require 'mechanize'
require 'pry'

host = Ask.input "API Host"
username = Ask.input "Username"
password = Ask.input("Password", password: true)

def get_resource(host, data)
  q = [ data['title'],
        data['authors'],
        data['keywords'],
        data['links'].map {|l| l['link']},
        data['sectors'].map {|s| "NY::#{s}"}
  ].flatten.join(" ")

  uri = URI.parse("#{host}/resources/?query=#{CGI.escape(q)}")
  resp = Net::HTTP.get(uri)
  JSON.parse(resp)
end

def create_geofocus(host,cookie, data)
  uri = URI.parse("#{host}/geofocuses")
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = uri.scheme == 'https'
  req = Net::HTTP::Post.new(uri.path,
        initheader = {'Content-Type' => 'application/json',
                      'Cookie' => cookie.to_s,
                      'Accept' => 'application/json'})
  req.body = JSON.generate({'geofocus' => {
    :name => data['name'],
    :uid => data['uid'],
    :type => data['type'],
    :geom => JSON.generate(data['geom'])
  }})
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

  file_to_import = Ask.input "Resources File to load"

  data_file = JSON.parse(File.read(file_to_import))
  data_file.each do |data|
    require 'pry'; binding.pry
    resp =  get_resource(host, data)

    # Do any match the same title?
    matches = resp['resources'].any? do |res|
      res['title'] == data['title']
    end

    if !matches
      # Create
     create_result = create_resource(host, cookie, data)
     puts "Created #{data['title']}".green
    else
      puts "Probably already exists".yellow
    end
  end
end
#sign_in_page = Net::HTTP.get(host, '/sign_in')
#puts sign_in_page
