require 'poise'

module ApacheTomcatInstance
  class Resource < Chef::Resource
    include Poise

    provides :apache_tomcat_instance
    actions :create

    attribute :name, kind_of: String
    attribute :prefix_root, kind_of: String, default: '/opt/tomcat'
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
    attribute :setenv,
              option_collector: true,
              template: true,
              default_source: 'setenv.sh.erb'
    attribute :create_default_web_xml,
              kind_of: [TrueClass, FalseClass],
              default: true
    attribute :create_default_server_xml,
              kind_of: [TrueClass, FalseClass],
              default: true
    attribute :create_default_context_xml,
              kind_of: [TrueClass, FalseClass],
              default: true
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat_instance

    def action_create
      notifying_block do
        create_instance_directories
        create_setenv_file if new_resource.setenv_options
        create_web_xml if new_resource.create_default_web_xml
        create_server_xml  if new_resource.create_default_server_xml
        create_context_xml  if new_resource.create_default_context_xml
      end
    end

    def instance_dir
      "#{new_resource.prefix_root}/#{new_resource.name}"
    end

    def create_instance_directories
      # Main directory for all instances
      directory new_resource.prefix_root do
        owner new_resource.user
        group new_resource.group
        mode '0750'
      end

      # Main instance directory
      directory instance_dir do
        owner new_resource.user
        group new_resource.group
        mode '0750'
      end

      # Sub-directories
      %w(bin conf lib logs temp webapps work).each do |dir|
        directory "#{instance_dir}/#{dir}" do
          owner new_resource.user
          group new_resource.group
          mode '0750'
        end
      end
    end

    def create_setenv_file
      file "#{instance_dir}/bin/setenv.sh" do
        content new_resource.setenv_content
        owner new_resource.user
        group new_resource.group
        mode '0750'
      end
    end

    class_eval do
      %w(web server context).each do |type|
        define_method "create_#{type}_xml" do
          apache_tomcat_config type do
            type type.to_sym
            instance new_resource.name
            config_options do
              include_defaults true
            end
          end
        end
      end
    end
  end
end
