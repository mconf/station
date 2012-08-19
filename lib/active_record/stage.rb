module ActiveRecord #:nodoc:
  # Each Stage defines a RBAC framework in your application.
  #
  # Stages have many Permissions. A Permission defines the Role an Agent plays in the Stage
  #
  # Include Stage functionality in your models using ActsAsMethods#acts_as_stage
  module Stage
    class << self
      def included(base) #:nodoc:
        base.extend ActsAsMethods
      end
    end

    module ActsAsMethods
      # Provide a model with Stage functionality
      #
      # Options:
      # admissions:: Support for inviting and requesting having a Role on this Stage. Defaults to true
      def acts_as_stage(options = {})
        ActiveRecord::Stage.register_class(self)

        options[:admissions] = true if options[:admissions].nil?

        cattr_reader :stage_options
        class_variable_set "@@stage_options", options

        has_many :stage_permissions,
                 :class_name => "Permission",
                 # Use delete_all to avoid Permission#avoid_destroying_only_one_with_highest_role callback
                 :dependent => :delete_all,
                 :as => :subject

        if options[:admissions]
          has_many :admissions,
                   :dependent => :destroy,
                   :as => :group
          has_many :invitations,
                   :dependent => :destroy,
                   :as => :group
          has_many :join_requests,
                   :dependent => :destroy,
                   :as => :group
        end

        extend  ClassMethods
        include InstanceMethods

        send :attr_accessor, :_stage_permissions
        after_save :_save_stage_permissions!
      end
    end

    module ClassMethods
      # The role name of this class
      def role(name)
        roles.find_by_name name
      end

      # All Roles defined for this class
      def roles
        Role.scoped_by_stage_type self.to_s
      end
    end

    # Instance methods can be redefined in each Model for custom features
    module InstanceMethods
      # True if agent has a Permission in this Stage.
      #
      # Options:
      # name:: Name of the Role
      #   space.role_for?(user, :name => 'Admin')
      def role_for?(agent, options = {})
        return false unless role_for(agent)

        options[:name] ?
          role_for(agent).name == options[:name] :
          true
      end
     
      # Role performed by this Agent in the Stage.
      #
      def role_for(agent)
        #FIXME: Role named scope
        Role.find :first,
                  :joins => :permissions,
                  :conditions => { 'permissions.user_id'   => agent.id,
                                   'permissions.subject_id'   => self.id,
                                   'permissions.subject_type' => self.class.base_class.to_s },
                  :include => :permissions
      end
      
      # Return all agents that play one role at least in this stage
      # 
      # Options:
      # role:: The Role actors are performing in this Stage
      def actors(options = {})
        conditions = {}

        if options[:role].present?
          conditions[:role_id] =
            case options[:role]
            when Role
              options[:role].id
            when String
              self.class.role(options[:role]).try(:id)
            when Fixnum
              options[:role]
            end
        end

        # Uses eager loading.
        # Compact the array, the agent may not be found because of default scopes.
        stage_permissions.where(conditions).includes(:user).map(&:user).compact
      end

      private

      def _save_stage_permissions! #:nodoc:
        return unless @_stage_permissions

        Permission.transaction do
          old_ps = stage_permissions.clone

          @_stage_permissions.each do |new_p|
            present_p = stage_permissions.find :first, :conditions => new_p

            present_p ?
              old_ps.delete(present_p) :
              stage_permissions.create!(new_p)
          end

          old_ps.map(&:destroy)
        end

        @_stage_permissions = nil
      end
    end
  end
end
