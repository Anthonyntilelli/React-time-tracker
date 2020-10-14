# frozen_string_literal: true

# Tracks all employee meals, breaks, and clock in/out
class ClockEvent < ApplicationRecord
  CATEGORY_ORDER = %w[ClockIn MealStart MealEnd BreakStart BreakEnd ClockOut].freeze

  belongs_to :employee

  validates :category, inclusion: { in: CATEGORY_ORDER, message: 'is not a valid clock event' }
  validates :triggered, presence: true
  validate :triggered_is_a_datetime
  validates :paidOut, inclusion: { in: [true, false] } # boolean validation
  validate :event_order, on: %i[create]

  after_validation :normalize_triggered, on: %i[create update]

  scope :unpaid, -> { where(paidOut: false) }
  scope :paid, -> { where(paidOut: true) }

  def self.hours_owed(listing)
    return 0 if listing.empty?

    time_point = nil
    hours_owed = 0
    listing.each do |ce|
      # time_point.nil? prevent breaks from changing time_point
      if !ce.pause_clock? && time_point.nil?
        time_point = ce.triggered
      elsif ce.pause_clock? && !time_point.nil?
        # convert from seconds to hours
        hours_owed += (ce.triggered - time_point) / 60 / 60
        time_point = nil
      end
      ce.update!(paidOut: true)
    end
    hours_owed
  end

  # Does event make it so no longer need to count hours
  def pause_clock?
    return true if category == 'ClockOut' || category == 'MealStart'

    false
  end

  private

  def triggered_is_a_datetime
    errors.add(:Tiggered, 'must be in utc') unless triggered.respond_to?(:utc?) && triggered.utc?
  end

  def normalize_triggered
    self.triggered = triggered.change(sec: 0)
  end

  # Enforce Event Creation order
  def event_order
    last_event = employee.clock_events.last
    return if last_event.nil?

    unless last_event.is_a?(ClockEvent)
      errors.add(:last_event, 'must be in a clock event')
      return
    end

    index = CATEGORY_ORDER.index(last_event.category)
    next_index = index == CATEGORY_ORDER.size - 1 ? 0 : index + 1
    errors.add(:Category, "Must be #{CATEGORY_ORDER[next_index]}") unless category == CATEGORY_ORDER[next_index]
  end
end
