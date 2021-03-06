Rails.application.routes.draw do

  apipie
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :questionnaires, only: [:index], defaults: { format: 'json' } do
        get '/', controller: :questionnaire_details, action: :show, defaults: { format: 'json' }, on: :member
        resources :questions, only: [:index], defaults: { format: 'json' } do
          get '/', controller: :question_details, action: :show, defaults: { format: 'json' }, on: :member
        end
      end
      get 'test_exception_notifier', controller: :base, action: :test_exception_notifier
    end
  end

  resources :questionnaires, only: [:index, :show]
  resources :user_sessions

  get 'login', to: "user_sessions#new", as: 'login'
  get 'logout', to: "user_sessions#destroy", as: 'logout'

  resources :users

  get 'signup', to: 'users#new', as: 'signup'
  post 'generate_new_token', to: 'users#generate_new_token', as: 'generate_new_token'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: "home#index"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
