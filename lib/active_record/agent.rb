require 'digest/sha1'

module ActiveRecord #:nodoc:
  # == acts_as_agent
  # Agents are models that can perform actions in the application. The paradigm of Agents are Users.
  #
  # Using Station, any of the models of your application can have Agent features. Nevertheless, having
  # only one model called User is the most common configuration.
  #
  # Agent functionality is declared with ActsAsMethods#acts_as_agent
  #
  #   class User
  #     acts_as_agent :authentication => [ :login_and_password, :openid ],
  #                   :openid_server => true
  #   end
  #
  #
  # == Authentication
  # Agents must provide some credentials to the web application in order to identify themselves.
  #
  # Station provides several methods to do so, from classic login and password to modern {OpenID}[http://openid.net/]. You can configure which methods will be used as an option in acts_as_agent
  #
  # See Authentication module for methods supported.
  #
  # == Authorization
  # Station uses an avanced access control model called the Authorization Chain. This provides you
  # flexibility to enforce miscelaneus authorization policies. See Authorization for more insight.
  #
  # === RBAC
  # Station provides Role-Based Access Control (RBAC) functionality within the Authorization framework.
  #
  # One of the Authorization Blocks defined by Station has to do with Stages. Agents perform a Role
  # in each Stage they participate. This Role defines the permissions the Agent can perform in the
  # scope of this Stage.
  #
  # == Singular Agents
  # Singular Agents are special models with Agent features. Each one represents a paradigm:
  # * Anonymous: the Agent behind a request without authentication credentials.
  # * Anyone: represents any Agent instance.
  # * CronAgent: the time-based job scheduler in Unix-like computer operating systems.
  #
  module Agent

    class << self

      # All Agent instances, sort by name
      def all
        classes.map(&:all).flatten.uniq.sort{ |x, y| x.name <=> y.name }
      end

      def included(base) #:nodoc:
        base.extend ActsAsMethods
      end
    end

    module ActsAsMethods
      # Provides an ActiveRecord model with Agent capabilities
      #
      # Options
      # <tt>invite</tt>:: Agent can be invited to application. Can be <tt>false</tt>. Defaults to <tt>:email</tt>
      def acts_as_agent(options = {})
        ActiveRecord::Agent.register_class(self)

        options[:invite] = :email if options[:invite].nil?

        # Set agent options
        #
        class << self
          attr_reader :agent_options
        end
        instance_variable_set "@agent_options", options

        if options[:invite]
          require "#{File.dirname(__FILE__)}/agent/invite"
          if table_exists? && ! column_names.include?(options[:invite].to_s)
            raise "#{ self.to_s } class hasn't column #{ options[:invite] }"
          end
          include Invite
        end

        has_many :agent_permissions,
                 :class_name => "Permission",
                 :dependent => :destroy,
                 :foreign_key => "user_id"

        extend  ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods

      protected

      def inherited(subclass) #:nodoc:
        super
        subclass.instance_variable_set "@agent_options", agent_options.dup
      end
    end

    module InstanceMethods

      # All Stages in which this Agent has a Permission
      #
      # Options:
      # type:: the class of the Stage requested (Doesn't work with STI!)
      #
      # Uses +compact+ to remove nil instances, which may appear because of default_scopes
      def stages(options = {})
        if options[:type]
          query = agent_permissions.where(:subject_type => options[:type])
        else
          query = agent_permissions
        end
        query.includes(:subject).all.map(&:subject).compact
      end

      # Agents that have at least one Role in stages
      def fellows
        stages.map(&:actors).flatten.compact.uniq.sort{ |x, y| x.name <=> y.name }
      end

      def service_documents
        Array.new
      end
    end
  end
end
