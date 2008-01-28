class CmsGenerator < Rails::Generator::Base
  default_options :skip_migration => false

  def initialize(runtime_args, runtime_options = {})
    parse!(runtime_args, runtime_options)
    super
  end

  def manifest
    record do |m|
      #TODO: check for collisions
      
      m.directory 'app/controllers'
      m.template  'controllers/posts_controller.rb', 'app/controllers/posts_controller.rb')

      m.template 'views/posts/new.erb',   'app/views/posts/new.erb'
      m.template 'views/posts/edit.erb',  'app/views/posts/edit.erb'
      m.template 'views/posts/_form.erb', 'app/views/posts/_form.erb'
      m.template 'views/posts/index.atom.builder', 'app/views/posts/index.atom.builder'
      m.template 'views/posts/post_entry.builder', 'app/views/posts/_entry.builder'
      
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate',
          :migration_file_name => "cms_setup"
      end
    end
  end
end