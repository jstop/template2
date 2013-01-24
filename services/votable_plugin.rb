module ActsAsListFu
  extend ActiveSupport::Concern

  included do
    key :position, Integer, :default => 1
  end

  module ClassMethods
    def reorder(ids)
      # reorder ids...
    end
  end

  module InstanceMethods
    def move_to_top
      # move to top
    end
  end
end	