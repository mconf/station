Rails.application.routes.draw do

  resources :tags

  resource :site do
    if Site.table_exists?
# TODO
      with_options :requirements => { :site_id => Site.current.id } do
        resources *ActiveRecord::Resource.symbols
      end
#
    end
  end

  resources *( ( ActiveRecord::Resource.symbols |
                 ActiveRecord::Content.symbols  |
                 ActiveRecord::Agent.symbols ) -
                 ActiveRecord::Container.symbols )

  ActiveRecord::Container.symbols.each do |container_sym|
    next if container_sym == :sites
    resources container_sym do
      resources(*container_sym.to_class.contents)
      resources :tags
    end
  end

  resources :logos

  resources(*(ActiveRecord::Logoable.symbols - Array(:sites))) do
    resource :logo
  end

  resources :invitations do
    get :accept, :as => :member
  end

  resources(*ActiveRecord::Stage.symbols - Array(:sites)) do
    resources :invitations
    resources :join_requests
  end
end
