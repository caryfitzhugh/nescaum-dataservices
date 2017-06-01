require 'aws-sdk'
module Cloudsearch
  class << self
    def add_documents(docs)
      cs_env = CONFIG.cs.env
      env_docs = docs.map do |doc|
        {type: "add",
         id: "#{cs_env}::#{doc[:docid]}",
         fields:{ uat: Time.now.utc.to_i,
                  env: cs_env,
                }.merge(doc)
        }
      end

      resp = upload_conn.upload_documents(
        documents: JSON.generate(env_docs),
        content_type: "application/json"
      )

      logger.info("Uploaded #{env_docs.length} documents")
      (resp.warnings || []).each do |warn|
        logger.warn(warn)
      end
      logger.info(resp.status)
      resp
    end

    def find_by_docid(docid)
      results = search_conn.search(filter_query: "docid:'#{docid}'",
                        query:"matchall",
                        query_parser: "structured")
      results.hits.hit[0]
    end

    def facet_list(name)
      #q=matchall&q.parser=structured
      result = search_conn.search(:query => "matchall", :query_parser => "structured", :facet => JSON.generate({ name => {:sort => :count}}))
      result.facets[name].buckets.select do |bucket|
        # Make sure it's a terminal node (no trailing ::)
        !(bucket.value =~ /::$/)
      end.map do |bucket|
        {name: bucket.value, count: bucket.count}
      end
    end

    def find_by_env(env_name)
      docs_in_env = search_conn.search(
        #return: "_no_fields",
        size: 100,
        start: 0,
        query: "matchall",
        query_parser: "structured",
        filter_query: "(and env:'#{env_name}')",
      )
    end

    def sync_to_db!(start: 0, batch: 100)
      # You want to find all the docids in cloudsearch at the moment.
    end

    def search_conn
      unless @search
        @search = Aws::CloudSearchDomain::Client.new(
          endpoint: CONFIG.cs.search_endpoint,
          access_key_id: CONFIG.cs.access_key,
          secret_access_key: CONFIG.cs.secret_key,
        )
      end
      @search
    end
    def upload_conn
      unless @upload
        @upload = Aws::CloudSearchDomain::Client.new(
          endpoint: CONFIG.cs.doc_endpoint,
          access_key_id: CONFIG.cs.access_key,
          secret_access_key: CONFIG.cs.secret_key,
        )
      end
      @upload
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
