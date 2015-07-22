require 'poise'

module ApacheTomcat
  class Resource < Chef::Resource
    include Poise

    provides :apache_tomcat
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
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat

    def action_install
      notifying_block do
        create_user
        install_archive
        remove_unnecessary_files
      end
    end

    def create_user
      Chef::Log.debug("Creating user #{new_resource.user} and group #{new_resource.group}")
      group new_resource.group

      user new_resource.user do
        gid new_resource.group
        comment 'Apache Tomcat'
        home new_resource.prefix_root
        shell '/sbin/nologin'
      end
    end

    def install_archive
      Chef::Log.debug("Installing #{new_resource.name} from archive")
      ark new_resource.name do
        url new_resource.url
        checksum new_resource.checksum
        version new_resource.version
        prefix_root new_resource.prefix_root
        prefix_home new_resource.prefix_root
        owner new_resource.user
        group new_resource.group
        append_env_path false
      end
    end

    def remove_unnecessary_files
      Chef::Log.debug("Removing unecessary base directories from #{home_dir}")
      dirs = %w(temp webapps work logs)
      dirs_to_delete = dirs.map { |dir| "#{home_dir}/#{dir}" }
      shell_out!("/bin/rm -rf #{dirs_to_delete.join(' ')}")
    end

    def home_dir
      "#{new_resource.prefix_root}/tomcat"
    end
  end
end
