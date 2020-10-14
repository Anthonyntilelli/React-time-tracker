# frozen_string_literal: true

# Tracks PTO
class Pto < ApplicationRecord
  belongs_to :employee

  validates :category, inclusion: { in: %w[Sick Pto], message: 'is not a valid PTO event' }
  validates :triggered, presence: true
  validate :triggered_is_a_datetime
  validates :paidOut, inclusion: { in: [true, false] } # boolean validation
  validates :hours, numericality: { greater_than: 0, only_integer: true }

  after_validation :normalize_triggered, on: %i[create update]

  scope :unpaid, -> { where(paidOut: false) }
  scope :paid, -> { where(paidOut: true) }

  def self.hours_owed(listing)
    return 0 if listing.empty?

    hours_owed = 0
    listing.each do |ce|
      hours_owed += ce.hours
      ce.update!(paidOut: true)
    end
    hours_owed
  end

  private

  def triggered_is_a_datetime
    errors.add(:Tiggered, 'must be in utc') unless triggered.respond_to?(:utc?) && triggered.utc?
  end

  def normalize_triggered
    self.triggered = triggered.change(sec: 0)
  end
end
