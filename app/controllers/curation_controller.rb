require 'app/models'

module Controllers
  class CurationController < Controllers::Base
    get "/curation", require_role: :curator, no_swagger: true  do
      erb :"curation/home"
    end
  end
end
