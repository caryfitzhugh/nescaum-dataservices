require './nds_app'
require 'inquirer'

namespace :db do
  task :install_postgis do
    require 'dm-migrations/migration_runner'

    migration 1, :postgis_extensions do
      up do
        execute "CREATE EXTENSION IF NOT EXISTS postgis"
      end
    end
    migration 2, :postgis_topology_extension do
      up do
        execute "CREATE EXTENSION IF NOT EXISTS postgis_topology"
      end
    end
    migration 3, :fuzzystrmatch_extension do
      up do
        execute "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch"
      end
    end
    migration 4, :postgis_tiger_extension do
      up do
        execute "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder"
      end
    end

    migrate_up!
  end
  task :migrate do

    DataMapper.auto_upgrade!
  end
  task :hard_migrate do
    DataMapper.auto_migrate!
  end

  namespace :users do
    task :list do
      users = User.find
      users.each do |user|
        puts user.attributes
      end
    end

    task :delete, [:id] do |t, args|
      user = User.get(args.id)
      if user && user.destroy
        puts "Deleted user"
      else
        puts "Failed to delete"
      end

    end

    task :create do |t, args|
      user = User.new
      user.username = Ask.input "Username"
      user.password = Ask.input("Password", password: true)
      user.name     = Ask.input "Name"
      user.email    = Ask.input "Email"
      user.roles    = [User::ROLES[Ask.list("Role", User::ROLES)]]

      if user.save
        puts "Created user:"
        puts user.attributes
      else
        puts "Failed to create: "
        puts user.errors.full_messages.join("\n")
      end
    end

    task :update_password do |t, args|
      username = Ask.input "Username"
      user = User.first(username: username)
      user.password = Ask.input("Password", password: true)

      if user.save
        puts "updated user:"
        puts user.attributes
      else
        puts "Failed to update: "
        puts user.errors.full_messages.join("\n")
      end
    end
  end
end

namespace :routes do
  desc "list defined routes"
  task :show do
    endpoints = {}

    #Modular application structure
    applications = [
      Controllers::ResourcesController,
      App,
    ].map(&:routes).flatten
    applications.each do |app|
      app.each do |verb,handlers|
        print "\n#{verb}:  "
        handlers.each do |handler|
          puts handler[0].to_s
        end
      end
    end
  end
end

namespace :rdf do
  task :import, [:path] do |t,args|
    require 'rdf'
    require 'linkeddata'
    uri = RDF::URI.new(args.path)
    graph = RDF::Repository.load(uri)
    graph.each_statement do |statement|
      puts statement
    end
    puts "graph: #{graph.statements.length}"
    require 'pry'; binding.pry
  end
end

namespace :cs do
  task :delete_from_cs do |t, args|
    to_remove = []
    res = Cloudsearch.iterate_all do |doc|
      require 'pry'; binding.pry
      docid = doc["fields"]["docid"][0]
      resource = Resource.get_by_docid(docid)
      if resource.nil?
        to_remove.push(docid)
      end
    end
    if to_remove.length > 0
      puts "Removing #{to_remove.length} records"
      Cloudsearch.remove_documents(to_remove)
    end
  end

  task :sync_to_cs do |t, args|
    # We want to iterate over the records in the DB in batches of 200.
    # Collect the list of docids to update

    Resource.all(indexed: true).each_chunk(100) do |chunk|
      resources_to_submit = []
      chunk.each do |resource|
        cs_resource = Cloudsearch.find_by_docid(resource.docid)
        if cs_resource.nil?
          resources_to_submit.push(resource)
        else
          uat = Time.at(cs_resource['fields']['uat'][0].to_i).to_datetime
          muat = resource.updated_at

          if muat > uat
            resources_to_submit.push(resource)
          end
        end
      end

      unless resources_to_submit.empty?
        Cloudsearch.add_documents(resources_to_submit.map(&:to_search_document))
      end
    end
  end

  task :truncate, [:env] do |t, args|
    puts "This will remove all documents from the CS index for this environment (up to 1000)"
    current = Cloudsearch.find_by_env(args.env)
    if current.hits.found == 0
      puts "There are no records in this environment."
      exit 0
    end

    puts "There are #{current.hits.found} records active"

    puts "This is non-recoverable.  Please confirm by entering the number of records that are active"

    number = Ask.input "# of active records to delete"

    if number.to_i == current.hits.found
      cs_ids = current.hits.hit.map(&:id)
      Cloudsearch.remove_by_cs_id(cs_ids)
      cs_ids.each do |cs_id|
        puts "  #{cs_id}"
      end
      puts "Scheduled for removal"
      until Cloudsearch.find_by_env(args.env).hits.found == 0 do
        sleep 3
      end
      puts "Done"
    else
      puts "Good idea. Aborting"
    end
  end
end
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "."
  t.test_files = FileList['test/**/*_test.rb']
end
