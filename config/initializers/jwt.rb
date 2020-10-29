# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
# Sets the JWT token secret
raise 'Missing JWT secret Keys from env' if ENV['RAILS_JWT_SECRET_KEY'].nil?
raise 'JWT secret cannot be <setme>' if ENV['RAILS_JWT_SECRET_KEY'] == '<setme>'
raise 'JWT ALG cannot be <setme>' if ENV['RAILS_JWT_ALG'] == '<setme>'
raise 'JWT ALG cannot be none' if ENV['RAILS_JWT_ALG'] == 'none'

ENV['RAILS_JWT_ALG'] ||= 'HS256'
JWT_SECRET_KEY = ENV['RAILS_JWT_SECRET_KEY']
JWT_ALG = ENV['RAILS_JWT_ALG']
