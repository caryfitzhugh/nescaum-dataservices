require 'aws-sdk'
module Cloudsearch
  class << self
    private
    def search
      unless @search
        @search = Aws::CloudsearchDomain::Client.new(
          endpoint: ENV["CLOUDSEARCH_SEARCH_ENDPOINT"],
          access_key_id: ENV["CLOUDSEARCH_ACCESS_KEY"],
          secret_access_key: ENV["CLOUDSEARCH_SECRET_KEY"],
        )
      end
      @search
    end
    def upload
      unless @upload
        @upload = Aws::CloudsearchDomain::Client.new(
          endpoint: ENV["CLOUDSEARCH_DOC_ENDPOINT"],
          access_key_id: ENV["CLOUDSEARCH_ACCESS_KEY"],
          secret_access_key: ENV["CLOUDSEARCH_SECRET_KEY"],
        )
      end
      @upload
    end
  end
end
