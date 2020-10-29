# frozen_string_literal: true

# Parent controller
class ApplicationController < ActionController::API
  before_action :validate_authorization

  # validate auth and sets up @employee
  def validate_authorization
    # Must have Authorization: Bearer
    if missing_bearer_token?
      return render json: { message: 'Missing Authorization header or not a Bearer token' }, status: :forbidden
    end

    token = request.headers['Authorization'].split(' ').last
    decode_settings = { algorithm: JWT_ALG, exp_leeway: 30, nbf_leeway: 30, verify_iat: true }
    decoded_body = JWT.decode(token, JWT_SECRET_KEY, true, decode_settings).first
    @employee = Employee.find_by!(name: decoded_body['name'])
  rescue JWT::ImmatureSignature,
         JWT::ExpiredSignature,
         JWT::InvalidJtiError,
         JWT::InvalidIatError,
         JWT::DecodeError => e
    render json: { message: "JWT ERROR #{e.message}" }, status: :forbidden
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Could not find employee.' }, status: :bad_request
  end

  private

  def missing_bearer_token?
    request.headers['Authorization'].nil? || request.headers['Authorization']&.split(' ')&.first != 'Bearer'
  end
end
