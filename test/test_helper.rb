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
    Controllers::Base.any_instance.expects(:current_user).at_least_once.returns(curator)
  end

  def app
    NDSApp.new
  end

  def setup
    current = Cloudsearch.find_by_env(CONFIG.cs.env)
    if current.hits.found > 0
      cs_ids = current.hits.hit.map(&:id)
      Cloudsearch.remove_by_cs_id(cs_ids)
      (puts('.') && sleep(1)) until Cloudsearch.find_by_env(CONFIG.cs.env).hits.found == 0
    end

    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  private

  def wait_for_cs_sync!()
    tgt = Resource.all(indexed: true).count
    (puts '.' && sleep(1)) until Cloudsearch.find_by_env(CONFIG.cs.env).hits.found == tgt
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
  def json_response
    JSON.parse(last_response.body)
  end
end
