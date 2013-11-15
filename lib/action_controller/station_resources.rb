module ActionController #:nodoc:
  # Controller methods for Resources
  #
  module StationResources
    class ContainerError < ::StandardError  #:nodoc:
    end

    class << self
      def included(base) #:nodoc:
        base.send :include, ActionController::Station unless base.ancestors.include?(ActionController::Station)
        base.class_eval do                                     # class ArticlesController
          alias_method controller_name, :resources             #   alias_method :articles, :resources
          helper_method controller_name                        #   helper_method :articles
          alias_method controller_name.singularize, :resource  #   alias_method :article, :resource
          helper_method controller_name.singularize            #   helper_method :article
        end                                                    # end

        base.send :rescue_from, ContainerError, :with => :container_error

        # base.send :include, ActionController::Authorization unless base.ancestors.include?(ActionController::Authorization)
      end
    end

    protected

    private

    # Redirect here after create if everythig went well
    def after_create_with_success
      redirect_to @resource
    end

    # Redirect here after create if there were errors
    def after_create_with_errors
      render :action => "new"
    end

    # Redirect here after update if everythig went well
    def after_update_with_success
      redirect_to @resource
    end

    # Redirect here after update if there were errors
    def after_update_with_errors
      render :action => "edit"
    end

    def container_error(e) #:nodoc:
      render :text => 'Container route conflicts with resource container',
             :status => 409
    end
  end
end
