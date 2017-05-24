require 'uri'

module Paths
  class << self
    {root: "/",
     resources: "/api/resources",
     sign_in: "/sign_in",
     sign_out: "/sign_out",
     curation_home: "/curation",
     swagger_root: "/index.html",
    }.each_pair do |key, val|
      define_method((key.to_s + "_path").to_sym) do |params = {}|
        add_q(val, params)
      end
    end

    private

    def add_q(path, params)
      uri = URI.parse(path)
      unless (params.empty?)
        uri.query = [uri.query, Rack::Utils.build_nested_query(params)].compact.join("&")
      end
      uri.to_s
    end
  end
end
