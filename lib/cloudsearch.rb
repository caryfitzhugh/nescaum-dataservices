require 'aws-sdk'

module Cloudsearch
  class << self

    def remove_documents(docids)
      cs_env = CONFIG.cs.env
      env_docs = docids.map do |docid|
        {type: "delete",
         id: "#{cs_env}::#{docid}",
        }
      end
      resp = upload_conn.upload_documents(
        documents: JSON.generate(env_docs),
        content_type: "application/json"
      )

      logger.info("Deleted #{env_docs.length} documents: #{docids.join(",")}")
      (resp.warnings || []).each do |warn|
        logger.warn(warn)
      end
      logger.info(resp.status)
      resp
    end

    def remove_by_cs_id(csids)
      env_docs = csids.map do |csid|
        {type: "delete", id: csid }
      end

      resp = upload_conn.upload_documents(
        documents: JSON.generate(env_docs),
        content_type: "application/json"
      )

      logger.info("Deleted #{env_docs.length} documents: #{csids.join(",")}")
      (resp.warnings || []).each do |warn|
        logger.warn(warn)
      end
      logger.info(resp.status)
      resp
    end

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

      logger.info("Uploaded #{env_docs.length} documents: #{docs.map {|d| d[:docid]}}")
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

    def iterate_all
      res = find_by_env(CONFIG.cs.env, size: 1)
      total = res.hits.found
      size = 100
      loops = (total / size) + 1
      loops.times do |n|
        res = find_by_env(CONFIG.cs.env, size: size, start: size * n)
        res.hits.hit.each do |hit|
          yield hit
        end
      end
    end

    def find_by_env(env_name, size: 1000, start: 0)
      docs_in_env = search_conn.search(
        return: "docid",
        size: size,
        start: start,
        query: "matchall",
        query_parser: "structured",
        filter_query: "(and env:'#{env_name}')",
      )
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
