require 'app/models'

module Controllers::Curation
  class HomeController < Controllers::Base
    get Paths.curation_home_path, require_role: :curator, no_swagger: true  do
      erb :"curation/home"
    end
  end
end
