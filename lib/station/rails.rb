module Station
  class Engine < ::Rails::Engine

    initializer 'station.all', :before => :load_config_initializers do |app|

      require 'will_paginate/array'
      directory = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

      # Make Station app/ paths reloadable
      ActiveSupport::Dependencies.autoload_once_paths.delete(File.expand_path(directory+'/app'))

      # Core Extensions
      require 'station/core_ext'

      require 'active_record/acts_as'
      ActiveRecord::Base.extend ActiveRecord::ActsAs

    end

  end
end
