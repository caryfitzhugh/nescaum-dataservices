
require 'app/models'

module Controllers
  class SectorsController < Controllers::Base
    get Paths.sectors_path, require_role: :curator do
      sectors = Models::Sector.find
    end
  end
end
