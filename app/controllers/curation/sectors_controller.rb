require 'app/models'

module Controllers::Curation
  class SectorsController < Controllers::Base
    get Paths.curation_sectors_path, require_role: :curator, no_swagger: true  do
      sectors = Models::Sector.find
      erb :"curation/sectors/index", locals: { sectors: sectors }
    end
  end
end
