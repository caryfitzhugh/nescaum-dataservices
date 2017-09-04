require './nds_app'
require 'inquirer'

namespace :db do
  task :seed do
    [
      "adaptation",
      "mitigation"
    ].each do |strategy|
      ResourceStrategy.first_or_create(value: strategy)
    end
    ResourceStrategy.all.each {|rs| rs.value=rs.value.downcase; rs.save }

    [
      "ma::agriculture",
      "ma::coastal zones",
      "ma::economy",
      "ma::forestry",
      "ma::infrastructure",
      "ma::local government",
      "ma::natural resources / habitats",
      "ma::public heatlh",
      "ma::public safety / emergency response",
      "ma::recreation",
      "ma::water resources",

      "ny::agriculture",
      "ny::buildings",
      "ny::coastal zones",
      "ny::ecosystems",
      "ny::energy",
      "ny::public health",
      "ny::telecommunications",
      "ny::transportation",
      "ny::water resources",
    ].each do |sector|
      ResourceSector.first_or_create(value: sector)
    end
    ResourceSector.all.each {|rs| rs.value=rs.downcase; rs.save }

    [
      "ma::outreach/education::capacity building",
      "ma::outreach/education::research and monitoring",
      "ma::planning::planning",
      "ma::planning::policies/laws/regulations",
      "ma::implementation action/direct action on target::management and behavior",
      "ma::implementation action/direct action on target::financing",
      "ma::implementation action/direct action on target::technology",
    ].each do |action|
      ResourceAction.first_or_create(value: action)
    end
    ResourceAction.all.each {|rs| rs.value=rs.downcase; rs.save }

    [
      "ma::rising temperatures::annual temperatures",
      "ma::rising temperatures::cloud cover",
      "ma::rising temperatures::cloud distribution",
      "ma::rising temperatures::evaporation",
      "ma::rising temperatures::extreme cold events",
      "ma::rising temperatures::extreme heat events",
      "ma::rising temperatures::growing season length",
      "ma::rising temperatures::ice cover",
      "ma::rising temperatures::in-stream temperature",
      "ma::rising temperatures::lake and pond temperature",
      "ma::rising temperatures::ocean temperature",
      "ma::rising temperatures::peak winds",
      "ma::rising temperatures::seasonal temperatures",
      "ma::rising temperatures::snow cover",
      "ma::rising temperatures::snowfall",
      "ma::rising temperatures::snowmelt ",
      "ma::rising temperatures::snowpack",
      "ma::rising temperatures::soil moisture",
      "ma::rising temperatures::wildfire",

      "ma::changes in precipitation::drought",
      "ma::changes in precipitation::soil moisture",
      "ma::changes in precipitation::evaportation",
      "ma::changes in precipitation::streamflow",
      "ma::changes in precipitation::lake levels",
      "ma::changes in precipitation::hydrology",
      "ma::changes in precipitation::inland flooding",
      "ma::changes in precipitation::annual precipitation",
      "ma::changes in precipitation::heavy precipitation",
      "ma::changes in precipitation::coastal flooding",
      "ma::changes in precipitation::seasonal precipitation",
      "ma::changes in precipitation::extreme precipitation events",
      "ma::changes in precipitation::snowcover",
      "ma::changes in precipitation::lake ice",
      "ma::changes in precipitation::flash flooding",

      "ma::extreme weather::hurricanes",
      "ma::extreme weather::nor'easters",
      "ma::extreme weather::intense winter storms",
      "ma::extreme weather::ice storms",
      "ma::extreme weather::heavy precipitation events",
      "ma::extreme weather::high wind",
      "ma::extreme weather::tornadoes",
      "ma::extreme weather::microbursts",
      "ma::extreme weather::hail",
      "ma::extreme weather::drought",
      "ma::extreme weather::wildfire",
      "ma::extreme weather::extreme heat",
      "ma::extreme weather::extreme cold",

      "ma::sea level rise::storm surge",
      "ma::sea level rise::ocean temperatures",
      "ma::sea level rise::ocean acidification",
      "ma::sea level rise::coastal flooding",
      "ma::sea level rise::salt-water intrusion",

    ].each do |climate_change|
      ResourceClimateChange.first_or_create(value: climate_change)
    end
    ResourceClimateChange.all.each {|rs| rs.value=rs.downcase; rs.save }

    [
      "Data::Data Product",
      "Data::Dataset",
      "Data::Decision Support",
      "Documents::Abstract",
      "Documents::Academic Article",
      "Documents::Article",
      "Documents::Blog Posting",
      "Documents::Book",
      "Documents::Building Code",
      "Documents::Case Study",
      "Documents::Catalog",
      "Documents::Chapter",
      "Documents::Comment",
      "Documents::Conference Paper",
      "Documents::Document Section",
      "Documents::Fact Sheet",
      "Documents::Guide",
      "Documents::Journal",
      "Documents::Law",
      "Documents::Manual",
      "Documents::Memo",
      "Documents::Newsletter",
      "Documents::Newspaper",
      "Documents::News Release",
      "Documents::Plan",
      "Documents::Proceedings",
      "Documents::Report",
      "Documents::Repository",
      "Documents::Series",
      "Documents::Software",
      "Documents::Thesis",
      "Documents::Video",
      "Documents::Working Paper",
      "Documents::White Paper",

      "Maps::GIS Layer",
      "Maps::Map",
      "Maps::Map Viewer ",
      "Maps::Decision Support",

      "Websites::Clearinghouse",
      "Websites::Website ",
      "Websites::Website Section",
      "Websites::Web-based Tool/Decision Support",

      "Events::Conference",
      "Events::Conference Series",
      "Events::Exhibit",
      "Events::Online Training",
      "Events::Presentation",
      "Events::Training",
      "Events::Webinar",
      "Events::Webinar Series",
      "Events::Workshop",

      "Project",
      "Person",
    ].each do |content_type|
      ResourceContentType.first_or_create(value: content_type)
    end
    ResourceContentType.all.each {|rs| rs.touch }
  end

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
