# frozen_string_literal: true

# Manages all clock event for employees
class ClockController < ApplicationController
  before_action :user_must_match_uid
  before_action :require_admin, only: :pay

  def show
    events = @target_employee.clock_events.map do |ce|
      { id: ce.id, category: ce.category, triggered: ce.triggered, paid_out: ce.paidOut }
    end

    render json: { events: events, count: events.count }, status: :ok
  end

  # show next clock event
  def next
    next_event = @target_employee.next_clock_event_category
    render json: { message: "Next event is #{next_event}", event: next_event }, status: :ok
  end

  # create clock event or finish day
  def create
    category = params.require(:category)
    unless ClockEvent::CATEGORY_ORDER.include?(category)
      return render json: { message: 'Invalid category' }, status: :bad_request
    end

    @target_employee.create_clock_event(category)
    render json: { message: 'Event Created' }, status: :ok
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { message: e.message }, status: :bad_request
  end

  # generate pay
  def pay
    full_date = params.require(:full_date)
    unless @target_employee.active
      return render json: { message: 'Inactive employees already paid out.' }, status: :bad_request
    end

    # Time.parse auto convert to utc
    hours = @target_employee.pay(Time.zone.parse(full_date.to_s))
    render json: { message: "Employee is owed #{hours} in hours.", pay: hours }, status: :ok
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid, ArgumentError => e
    render json: { message: e.message }, status: :bad_request
  end

  private

  # Employee id must match url_id unless admin
  # return 4xx if Employee by id does not exist
  # sets @Target_employee
  def user_must_match_uid
    target_id = require_id

    if !@employee.admin && require_id != @employee.id.to_s
      return render json: { message: 'Not allowed to access this data' }, status: :forbidden
    end
    unless Employee.exists?(target_id)
      return render json: { message: 'Unable to find employee by provided id.' }, status: :not_found
    end

    @target_employee = Employee.find(target_id)
  end
end
