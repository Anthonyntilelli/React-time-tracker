# frozen_string_literal: true

# Manage Login
class SessionsController < ApplicationController
  skip_before_action :validate_authorization, only: :create

  def create
    name = Employee.normalize_name(params.require(:name))
    employee = Employee.find_by(name: name)&.authenticate(params.require(:password))
    # Inactive users should not be able to login
    unless employee && employee&.active
      return render json: { message: 'Incorrect Name or password' }, status: :forbidden
    end

    render json: { message: 'Login Successfull', token: gen_jwt(employee) }, status: :ok
  rescue ActionController::ParameterMissing => e
    render json: { message: e.message }, status: :bad_request
  end

  private

  def gen_jwt(employee)
    iat = Time.current.to_i
    payload = {
      id: employee.id,
      name: employee.name,
      admin: employee.admin,
      exp: (Time.current + 1.day).to_i, # Expire
      nbf: Time.current.to_i, # Not valid before
      iat: iat # Issues at time
    }
    JWT.encode(payload, JWT_SECRET_KEY, JWT_ALG, { typ: 'JWT' })
  end
end
