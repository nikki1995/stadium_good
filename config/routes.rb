Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'api/v1/social_site#responses'

  namespace :api do
    namespace :v1 do
      resources :social_site do
        collection do
          get :responses
        end
      end
    end
  end
end
