ServerCode::Application.routes.draw do

  resources :friendships #define the use of the friendsips MVC
  post '/' => 'users#index', :defaults => {:format => 'json'} #direct the root '/' to users index method
  resources :users #define the use of the users MVC
  get 'logout' => 'user_sessions#destroy', :as => 'logout' #destroy the users session on logout
  get 'login' => 'user_sessions#new', :as => 'login' #begin making new session for login
  post 'login' => 'user_sessions#create' #create new user session on successful login
  post 'mym' => 'moments#edit', :as => 'mym' #allow a post for the user [DEPRECATED]
  get 'mym' => 'users#show', :as => 'mym' #show the user's latest moment [DEPRECATED]
  get 'confirm_friendship' => 'friendships#create' #create a friendship through confirmation link
  post 'edit_user' => 'users#update', :defaults => {:format => 'json'} #edit the password or email of a user
  post 'delete_user' => 'users#destroy', :defaults => {:format => 'json'} #delete a user and all friendships
  post 'createfriend' => 'friendships#new', :defaults => {:format => 'json'} #invite another user to be friends
  post 'friends' => 'friendships#show', :defaults => {:format => 'json'} #show all of a user's friends
  post 'deletefriend' => 'friendships#destroy', :defaults => {:format => 'json'} #delete a friendship
  post 'get_user' => 'users#show', :defaults => {:format => 'json'} #returns the email for a given user
  post 'get_all_users' => 'users#index', :defaults => {:format => 'json'} #returns all users in an array
  resources :user_sessions, :except => [:index, :edit] #define the use of the user_sessions MVC
  root :to => 'users#index' #direct the root for the web server to the index method
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
