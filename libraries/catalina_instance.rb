require 'poise'

module CatalinaInstance
  class Resource < Chef::Resource
    include Poise

    provides :catalina_instance
    actions :create

    attribute :name, kind_of: String
    attribute :prefix_root, kind_of: String, default: '/opt/tomcat'
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
    attribute :setenv_variables, kind_of: Hash
    attribute :setenv_template_source, kind_of: String, default: 'setenv.sh.erb'
    attribute :cookbook, kind_of: String, default: 'catalina'
    # TODO: Allow creation of default web and server XML
    # TODO: Change this to use the poise template attribute type
  end

  class Provider < Chef::Provider
    include Poise

    provides :catalina_instance

    def action_create
      notifying_block do
        create_instance_directories
        create_setenv_file
      end
    end

    def instance_dir
      "#{new_resource.prefix_root}/#{new_resource.name}"
    end

    def create_instance_directories
      # Main directory for all instances
      directory "#{new_resource.prefix_root}" do
        owner new_resource.user
        group new_resource.group
        mode '0755'
      end

      # Main instance directory
      directory instance_dir do
        owner new_resource.user
        group new_resource.group
        mode '0755'
      end

      # Sub-directories
      %w(bin conf lib logs temp webapps work).each do |dir|
        directory "#{instance_dir}/#{dir}" do
          owner new_resource.user
          group new_resource.group
          mode '0755'
        end
      end

      def create_setenv_file
        template "#{instance_dir}/bin/setenv.sh" do
          source new_resource.setenv_template_source
          owner new_resource.user
          group new_resource.group
          mode '0750'
          cookbook new_resource.cookbook
          variables new_resource.setenv_variables
        end
      end
    end
  end
end
