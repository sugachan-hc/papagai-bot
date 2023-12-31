Rails.application.routes.draw do
  get 'hello/index' => 'hello#index'
  # get 'hello/index'
  post 'callback' => 'line_bot#callback'
end
