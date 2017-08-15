ENV['APP_ENV'] = 'test'
ENV["SESSION_SECRET"] = 'test'
require './nds_app'

require 'webrat'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

require 'app/models'
require 'rack/test'
require 'test/unit'
require 'mocha/test_unit'
require 'pry'
DataMapper.auto_migrate!

Webrat.configure do |config|
  config.mode = :rack
end

class NDSTestBase < Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  def login_curator!
    curator = User.new(username: "curator", password: "password",
                       name: "curator", email: "curator@cure.com",
                       roles: ['curator'])
    curator.raise_on_save_failure = true
    curator.save
    Controllers::Base.any_instance.expects(:current_user).at_least_once.returns(curator)
  end

  def app
    NDSApp.new
  end
  def setup
    truncate_cs!
    Resource.custom_docid_prefix Time.now.to_i.to_s
    DatabaseCleaner.start
  end

  def teardown
    truncate_cs!
    Resource.custom_docid_prefix nil
    DatabaseCleaner.clean
  end

  private

  def truncate_cs!
    current = Cloudsearch.find_by_env(CONFIG.cs.env)
    puts current.hits.hit.map(&:id)
    print "clearing CS..."
    until Cloudsearch.find_by_env(CONFIG.cs.env).hits.found == 0 do
      cs_ids = current.hits.hit.map(&:id)
      Cloudsearch.remove_by_cs_id(cs_ids)
      sleep 3
    end
  end

  def wait_for_cs_sync!()
    tgt = Resource.all(indexed: true).count
    Resource.all.each(&:sync_index!)
    puts "Target: #{tgt}"

    until Cloudsearch.find_by_env(CONFIG.cs.env).hits.found == tgt do
      Resource.all.each do |res|
        res.sync_index!
        puts res.docid
      end
      puts Cloudsearch.find_by_env(CONFIG.cs.env).hits.found
      sleep 3
    end
  end

  def url_for(path, params = {})
    uri = URI.parse(path)
    unless (params.empty?)
      uri.query = [uri.query, Rack::Utils.build_nested_query(params)].compact.join("&")
    end
    uri.to_s
  end

  def post_json(uri, body)
    post(uri, JSON.generate(body), { "CONTENT_TYPE" => "application/json" })
  end

  def put_json(uri, body)
    put(uri, JSON.generate(body), { "CONTENT_TYPE" => "application/json" })
  end

  def json_response
    JSON.parse(last_response.body)
  end

  private

  def geom(k)
    coords = {
      far_small: [[10,10],[11,10],[11,11],[10,11],[10,10]],
      far_large: [[10,10],[20,10],[20,20],[10,20],[10,10]],
      near_small: [[0,0],[1,0],[1,1],[0,1],[0,0]],
      near_large: [[0,0],[5,0],[5,5],[0,5],[0,0]],
    }[k]

    ring = GeoRuby::SimpleFeatures::LinearRing.from_coordinates(coords, 4326)
    GeoRuby::SimpleFeatures::Polygon.from_linear_rings([ring])
  end

  def geom_doc(gfs)
    resource = Resource.new(
      title: "#{gfs.map(&:name).join(",")}",
      indexed: true,
      published_on_end: Date.today.to_s,
      published_on_start: Date.today.to_s,
      geofocuses: gfs.map(&:id)
    )
    assert resource.save
    resource
  end
end
