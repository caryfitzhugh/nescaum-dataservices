ENV['APP_ENV'] = 'test'
ENV["SESSION_SECRET"] = 'test'
require './nds_app'

require 'webrat'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

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
    curator = Models::User.new(username: "curator", password: "password",
                       name: "curator", email: "curator@cure.com",
                       roles: ['curator'])
    Controllers::Base.any_instance.expects(:current_user).at_least_once.returns(curator)
  end

  def app
    NDSApp.new
  end

  def setup
    cs_query_enable
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  private
  def cs_query_enable
    Aws::Plugins::RequestSigner::Handler.any_instance.expects(:unsigned_request?).at_most(100).returns(true)
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
