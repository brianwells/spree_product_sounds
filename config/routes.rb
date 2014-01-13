Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :products do
      resources :sounds do 
        collection do 
        	post :update_positions
      	end    
      end
    end
  end
end
