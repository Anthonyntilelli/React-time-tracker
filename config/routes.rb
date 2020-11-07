# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope :api do
    post '/login' => 'sessions#create'
    resource :employee, except: %i[update destroy]
    get '/employee/:url_id' => 'employees#self_show', as: :employee_self_show
    put '/employee/:url_id' => 'employees#update'
    patch '/employee/:url_id' => 'employees#update'
    delete '/employee/:url_id' => 'employees#destroy'
  end
end
