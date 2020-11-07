# frozen_string_literal: true

# EMployee controller
class EmployeesController < ApplicationController
  before_action :require_admin, only: %i[show update create destroy]
  before_action :match_url_id_to_user, only: :self_show

  # Hire
  def create
    hire_name = params.require(:hire_name)
    hire_password = params.require(:hire_password)
    hire_is_admin = params.require(:hire_is_admin)
    pto_rate = params.require(:pto_rate)
    pto_max = params.require(:pto_max)

    new_hire = Employee.hire(hire_name, hire_password, pto_rate, pto_max, is_admin: hire_is_admin, admin: @employee)
    render json: employee_json(new_hire), status: :created
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { message: e.message }, status: :bad_request
  end

  # Got info on yourself or other
  def show
    all = Employee.all.map { |e| { id: e.id, name: e.name, active: e.active, admin: e.admin } }
    render json: all, status: :ok
  end

  # Get info on any employee
  def self_show
    render json: employee_json(Employee.find(params[:url_id])), status: :ok
  end

  # Change employee's pto settings
  def update
    target_id = require_id
    unless Employee.exists?(target_id)
      return render json: { message: 'Unable to find employee by provided id.' }, status: :not_found
    end

    reason = params.require(:reason)
    pto_rate = params.require(:pto_rate)
    pto_max = params.require(:pto_max)
    pto_current = params.require(:pto_current)
    modify_employee = Employee.find(target_id)
    modify_employee.modify_pto(@employee, reason, rate: pto_rate, max: pto_max, current: pto_current)
    render json: employee_json(modify_employee), status: :ok
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { message: e.message }, status: :bad_request
  end

  def destroy
    target_id = require_id
    unless Employee.exists?(target_id)
      return render json: { message: 'Unable to find employee by provided id.' }, status: :not_found
    end

    reason = params.require(:reason)
    terminated = Employee.find(target_id)
    pay = terminated.end_employment(@employee, reason)
    render json: { message: "Employeed Terminated, they are owed #{pay} in hours.", pay: pay }, status: :ok
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { message: e.message }, status: :bad_request
  rescue ArgumentError => e
    render json: { message: e.message }, status: :gone
  end

  private

  def employee_json(emp)
    emp.to_json(only: %i[id name pto_rate pto_current pto_max admin active])
  end

  # Employee id must match url_id unless admin
  def match_url_id_to_user
    url_id = params.require(:url_id)
    if !@employee.admin && url_id != @employee.id.to_s
      return render json: { message: 'Not allowed to access this data' }, status: :forbidden
    end

    render json: { message: 'Unable to find employee by that id.' }, status: :not_found unless Employee.exists?(url_id)
  rescue ActionController::ParameterMissing => e
    render json: { message: e.message }, status: :bad_request
  end
end
