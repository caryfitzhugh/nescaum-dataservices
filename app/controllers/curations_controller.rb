require 'app/models'

module Controllers
  class CurationController < Controllers::Base
    get Paths.curation_home_path, require_curator: true, no_swagger: true  do
      unless current_user.curator?

      end
    end
  end
end
