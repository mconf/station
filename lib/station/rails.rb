module Station
  class Engine < ::Rails::Engine

    initializer 'station.all', :before => :load_config_initializers do |app|

      require 'will_paginate/array'
      directory = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

      # Make Station app/ paths reloadable
      ActiveSupport::Dependencies.autoload_once_paths.delete(File.expand_path(directory+'/app'))

      # Core Extensions
      require 'station/core_ext'

      # ActiveRecord
      require 'active_record/authorization'
      ActiveRecord::Base.send :include, ActiveRecord::Authorization

      require 'active_record/acts_as'
      ActiveRecord::Base.extend ActiveRecord::ActsAs

      # Initialize all Singular Agents
      if SingularAgent.table_exists?
        SingularAgent
        Anonymous.current
        Anyone.current
        Authenticated.current
      end

      # Mime Types
      # Redefine Mime::ATOM to include "application/atom+xml;type=entry"
      # Mime::Type.register "application/atom+xml", :atom, [ "application/atom+xml;type=entry" ]
      Mime::Type.register "application/atomsvc+xml", :atomsvc
      Mime::Type.register "application/atomcat+xml", :atomcat
      Mime::Type.register "application/xrds+xml",    :xrds

      # ActionController
      require "action_controller/station"
      require "action_controller/authentication"
      require "action_controller/authorization"
      for mod in [ ActionController::Station, ActionController::Authentication, ActionController::Authorization ]
        ActionController::Base.send(:include, mod) unless ActionController::Base.ancestors.include?(mod)
      end

      # ActionView
      # Helpers
      %w( logos sortable station tags ).each do |item|
        require_dependency "action_view/helpers/#{ item }_helper"
        ActionView::Base.send :include, "ActionView::Helpers::#{ item.camelcase }Helper".constantize
      end

      # FormHelpers
      %w( logo tags ).each do |item|
        require_dependency "action_view/helpers/form_#{ item }_helper"
        ActionView::Base.send :include, "ActionView::Helpers::Form#{ item.camelcase }Helper".constantize
      end

      # Inflections
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.uncountable 'cas'
        inflect.uncountable 'anonymous'
      end

      # i18n
      locale_files =
        Dir[ File.join(File.join(directory, 'config', 'locales'), '*.{rb,yml}') ]

      if locale_files.present?
        first_app_element =
          I18n.load_path.select{ |e| e =~ /^#{ Rails.root.to_s }/ }.reject{ |e|
          e =~ /^#{ Rails.root.to_s }\/vendor\/plugins/ }.first

        app_index = I18n.load_path.index(first_app_element) || - 1

        I18n.load_path.insert(app_index, *locale_files)
      end

      # # Models Preload
      file_patterns = [ directory, Rails.root.to_s ].map{ |f| f + '/app/models/**/*.rb' }
      file_exclusions = ['svn', 'CVS', 'bzr']
      file_patterns.reject{ |f| f =~ /#{file_exclusions.join("|")}/ }

      preloaded_files = []
      # # # Lazy files need other files to be loaded first
      lazy_files = [ ]

      # # Find all source files that need preloading
      file_patterns.each do |file_pattern|
        Dir[file_pattern].each do |filename|
          open filename do |file|
            preloaded_files << filename if file.grep(/acts_as_(#{ ActiveRecord::ActsAs::Features.join('|') })/).any?
          end
        end
      end

      # # # If there are overwritten engine files in the application, load them
      # # # instead of the engine ones.
      # #
      # # If you only want to add functionality, you should use:
      # #   require_dependency "#{ Rails.root.to_s }/path/to/the/engine/file"
      # # on the top of the application file and then reopen the class
      # #
      # preloaded_files.select{ |f| f =~ /^#{ directory }/ }.each do |f|
      #   app_f = f.gsub(directory, Rails.root.to_s)
      #   if File.exists?(app_f)
      #     preloaded_files |= [ app_f ]
      #     preloaded_files.delete(f)
      #   end
      # end

      # # # Move lazy files to the end
      # lazy_files.each do |lf|
      #   f = preloaded_files.find{ |pf| pf =~ /#{ lf }$/ }
      #   preloaded_files << preloaded_files.delete(f)
      # end

      # # Finally, preload files
      preloaded_files.each do |f|
        begin
          require_dependency(f)
        rescue Exception => e
          #FIXME: logger ?
          puts "Station autoload: Couldn't load file #{ f }: #{ e }"
        end
      end

      ActiveSupport.on_load(:active_record) do

        # Modifications of Station Engine
        # In Global authorization, users that are superusers are gods
        # This module allows implementing this feature in all classes that implement authorizes?
        module ActiveRecord::Authorization::InstanceMethods
          alias authorize_without_superuser authorize?

          def authorize_with_superuser(permission, options = { })
            return true if options[:to] && options[:to].superuser

            authorize_without_superuser(permission, options)
          end

          alias authorize? authorize_with_superuser
        end

      end

    end

  end
end

