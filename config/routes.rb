Rails.application.routes.draw do
  get 'docs(/:product_name)', :to => 'docs#show', :as => :docs_page
end
