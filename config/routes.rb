Rails.application.routes.draw do
  # jsonapi_resources :datasets
  # jsonapi_resources :allocators
  # jsonapi_resources :prefixes
  # jsonapi_resources :datacentres, constraints: { :id => /.+/ }
  resources :datacentres, constraints: { :id => /.+/ }
  # resources :datasets
  resources :datasets, constraints: { :id => /.+/ }
  resources :prefixes, constraints: { :id => /.+/ }
  resources :allocators
  resources :members, controller: 'allocators'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
