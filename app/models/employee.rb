# frozen_string_literal: true

# Employee Model tracks employee base data
class Employee < ApplicationRecord
  # has_many :time_clock, foreign_key: "employee", class_name: "ClockEvent"
  has_many :clock_events, dependent: :destroy
  has_many :admin_events, dependent: :destroy
  has_many :ptos, dependent: :destroy

  has_secure_password

  before_validation :normalize_provided_name, on: %i[create update]

  validates :name, presence: true,
                   format: { with: /[A-Za-z]+\s[A-Za-z]+/, message: 'must be First and Last name' }, uniqueness: true

  # has secure password is limited to 72 bytes max
  validates :password, presence: true, length: { in: 8..72 }, if: -> { password_digest_changed? }
  validates :pto_rate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pto_current, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pto_max, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :admin, inclusion: { in: [true, false] } # boolean validation
  validates :active, inclusion: { in: [true, false] } # boolean validation

  # Create employee without repeating cetain fields and adds hire event
  def self.hire(name, password, pto_rate, pto_max, is_admin: false, admin: -1)
    admin_id = admin.is_a?(Employee) ? admin.id : -1
    new_employee = Employee.new(name: name, password: password, pto_rate: pto_rate,
                                pto_current: 0, pto_max: pto_max, admin: is_admin, active: true)
    new_employee.save!
    # Create hire admin event
    new_employee.admin_events.create!(admin: admin_id, action: 'Hire', reason: 'Initial Hire')
    new_employee
  end

  def self.normalize_name(name)
    name.strip.downcase.titleize
  end

  # Calculates Pay hours and makes clock events as paid
  def pay(time)
    raise 'Time must be utc' unless time.respond_to?(:utc?) && time.utc?

    ce_hours = ClockEvent.hours_owed(clock_events.unpaid.where('triggered <= ?', time))
    pto_hours = Pto.hours_owed(ptos.unpaid.where('triggered <= ?', time))
    ce_hours + pto_hours
  end

  # add PTO based on rate up to max
  def add_pto
    new_pto = pto_current + pto_rate
    update!(pto_current: new_pto <= pto_max ? new_pto : pto_max)
  end

  def at_pto_max?
    pto_max == pto_current
  end

  # Adds all clock event to clock user out.
  def finish_day(time: Time.zone.now)
    # Day already over
    return false if clock_events.last.category == ClockEvent::CATEGORY_ORDER[-1]

    start = ClockEvent::CATEGORY_ORDER.index(clock_events.last.category)
    ClockEvent::CATEGORY_ORDER[start + 1..].each do |type|
      clock_events.create!(category: type, triggered: time, paidOut: false)
    end
    true
  end

  def next_clock_event_category
    current_category = clock_events&.last&.category
    return ClockEvent::CATEGORY_ORDER[0] if current_category.nil?

    current_index = ClockEvent::CATEGORY_ORDER.index(current_category)
    ClockEvent::CATEGORY_ORDER[(current_index + 1) % ClockEvent::CATEGORY_ORDER.size]
  end

  def create_clock_event(category, time: Time.zone.now)
    raise ArgumentError, 'category must be a string' unless category.is_a?(String)

    clock_events.create!(category: category, triggered: time, paidOut: false)
  end

  # Must have avaible time at request
  def use_pto(hours, time: Time.zone.now)
    add_pto_event('Pto', time, hours)
  end

  # Must have avaible time at request
  def sick(hours, time: Time.zone.now)
    add_pto_event('Sick', time, hours)
  end

  ## Admin Actions ##
  # All Action require an admin to use.

  # End employees account access and returns hours + pto payment owed.
  # Employee record is not removed.
  def end_employment(admin, reason)
    raise ArgumentError, 'Employee is not active, cannot re-end employment' unless active

    admin_events.create!(admin: admin.id, action: 'EndEmployment', reason: reason)
    # max size of has_secure_password is 72 (HEX(36)) and scramble access password just in case.
    update!(password: SecureRandom.hex(36), active: false)
    pay(Time.zone.now)
  end

  def modify_pto(admin, reason, rate: pto_rate, max: pto_max, current: pto_current)
    admin_events.create!(admin: admin.id, action: 'ModifyPTO', reason: reason)
    update!(pto_rate: rate, pto_max: max, pto_current: current)
  end

  private

  def normalize_provided_name
    self.name = Employee.normalize_name(name)
  end

  # returns false if not enough hours
  def add_pto_event(category, time, hours)
    raise 'hours must be an positive integer' unless hours.is_a?(Integer) && hours.positive?

    remaining = pto_current - hours
    return false if remaining.negative?

    update!(pto_current: remaining)
    finish_day(time: time)
    ptos.create!(category: category, triggered: time, paidOut: false, hours: hours)
    true
  end
end
