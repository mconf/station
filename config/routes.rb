Rails.application.routes.draw do

  resources :tags

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

  unless ActiveRecord::Logoable.symbols.empty?
    resources(*(ActiveRecord::Logoable.symbols - Array(:sites))) do
      resource :logo
    end
  end

end
