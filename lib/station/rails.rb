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

      # Mime Types
      # Redefine Mime::ATOM to include "application/atom+xml;type=entry"
      # Mime::Type.register "application/atom+xml", :atom, [ "application/atom+xml;type=entry" ]
      Mime::Type.register "application/atomsvc+xml", :atomsvc
      Mime::Type.register "application/atomcat+xml", :atomcat
      Mime::Type.register "application/xrds+xml",    :xrds

      # ActionController
      require "action_controller/station"
      # require "action_controller/authorization"
      for mod in [ ActionController::Station ] # , ActionController::Authorization
        ActionController::Base.send(:include, mod) unless ActionController::Base.ancestors.include?(mod)
      end

      # ActionView
      # Helpers
      %w( tags ).each do |item|
        require_dependency "action_view/helpers/#{ item }_helper"
        ActionView::Base.send :include, "ActionView::Helpers::#{ item.camelcase }Helper".constantize
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

    end

  end
end
