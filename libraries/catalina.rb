require 'poise'

module Catalina
  class Resource < Chef::Resource
    include Poise

    provides :catalina
    actions :install, :uninstall

    attribute :name, kind_of: String
    attribute :url,
              kind_of: String,
              default: 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz'
    attribute :checksum,
              kind_of: String,
              default: '41980bdc3a0bb0abb820aa8ae269938946e219ae2d870f1615d5071564ccecee'
    attribute :version, kind_of: String, default: '8.0.24'
    attribute :prefix_root, kind_of: String, default: '/usr/share'
    attribute :prefix_home, kind_of: String, default: '/usr/share'
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
  end

  class Provider < Chef::Provider
    include Poise

    provides :catalina

    def action_install
      notifying_block do
        create_user

        ark new_resource.name do
          url new_resource.url
          checksum new_resource.checksum
          version new_resource.version
          prefix_root new_resource.prefix_root
          prefix_home new_resource.prefix_home
          owner new_resource.user
        end

        remove_unecessary_files
      end
    end

    def create_user
      Chef::Log.warn("Creating user #{new_resource.user} and group #{new_resource.group}")
      group new_resource.group

      user new_resource.user do
        gid new_resource.group
        comment 'Apache Tomcat'
        home new_resource.prefix_home
        shell '/sbin/nologin'
      end
    end

    def remove_unecessary_files
      Chef::Log.warn("Removing unecessary base directories from #{new_resource.prefix_home}/tomcat")
      dirs = %w(temp webapps work logs)
      dirs_to_delete = dirs.map { |dir| "#{new_resource.prefix_home}/tomcat/#{dir}" }
      shell_out!("/bin/rm -rf #{dirs_to_delete.join(' ')}")
    end
  end
end
