require 'poise'

module CatalinaInstance
  class Resource < Chef::Resource
    include Poise

    provides :catalina_instance
    actions :create, :destroy

    attribute :name, kind_of: String
    attribute :prefix_root, kind_of: String, default: '/opt/tomcat'
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
  end

  class Provider < Chef::Provider
    include Poise

    provides :catalina_instance

    def action_create
      notifying_block do
        create_instance_directories
        # Copy files
        # Scripts?
      end
    end

    def create_instance_directories
      # Main directory for all instances
      directory "#{new_resource.prefix_root}" do
        owner new_resource.user
        group new_resource.group
        mode '0755'
      end

      # Main instance directory
      directory "#{new_resource.prefix_root}/#{new_resource.name}" do
        owner new_resource.user
        group new_resource.group
        mode '0755'
      end

      # Sub-directories
      %w(bin conf lib logs temp webapps work).each do |dir|
        directory "#{new_resource.prefix_root}/#{new_resource.name}/#{dir}" do
          owner new_resource.user
          group new_resource.group
          mode '0755'
        end
      end
    end
  end
end
