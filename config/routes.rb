Rails.application.routes.draw do
  get 'docs(/:product_name)', :to => 'docs#show', :as => :docs_page
  get 'terms', :to => 'docs#tos', :as => :terms_of_service
  get 'privacy', :to => 'docs#privacy', :as => :privacy_policy
end
