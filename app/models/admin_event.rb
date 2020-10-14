# frozen_string_literal: true

# Record of all admin events on employee data and time.
class AdminEvent < ApplicationRecord
  belongs_to :employee

  validates :admin, presence: true
  validate :require_admin
  validates :action, inclusion: { in: %w[Hire EndEmployment ModifyPTO], message: 'is not a valid action' }
  validates :reason, length: { maximum: 100 }

  def admin_resolved
    return Employee.new(name: 'system', admin: true) if admin == -1

    Employee.find(admin)
  end

  private

  # Ensure admin is correct
  def require_admin
    return if admin == -1

    unless admin.is_a?(Integer)
      errors.add(:admin, 'must be an Employee id')
      return
    end
    errors.add(:admin, 'must be an admin') unless Employee.find(admin).admin
  end
end
