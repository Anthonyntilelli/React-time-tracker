# frozen_string_literal: true

# Model Base
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
