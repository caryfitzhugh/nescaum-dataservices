module Models
  module Resource
    def self.included(klass)
      klass.belongs_to :sector
    end
  end
end
