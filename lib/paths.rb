require 'uri'

module Paths
  class << self
    def root_path(params ={})
      add_q("/", params)
    end

    def add_q(path, params)
      uri = URI.parse(path)
      unless (params.empty?)
        uri.query = [uri.query, Rack::Utils.build_nested_query(params)].compact.join("&")
      end
      uri.to_s
    end
  end
end
