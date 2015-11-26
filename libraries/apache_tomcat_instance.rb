# Copyright 2015 Drew A. Blessing
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'poise'

module ApacheTomcatInstance
  class Resource < Chef::Resource
    include Poise

    # Sets this resource as a subresource container.
    # `false` means not to namespace the resources
    poise_subresource_container false

    # This resource is also a subresource of `apache_tomcat_instance`
    poise_subresource :apache_tomcat

    provides :apache_tomcat_instance
    actions :create

    attribute :name, kind_of: String
    attribute :setenv,
              option_collector: true,
              template: true,
              default_source: 'config-file.erb'
    attribute :setcron,
              option_collector: true,
              template: true,
              default_source: 'config-file.erb'
    attribute :bundle_webapps_enabled,
              kind_of: Array,
              default: []
    attribute :bundle_webapps_managed,
              kind_of: Array,
              default: []

    def instance_dir
      "#{parent.instance_root}/#{name}"
    end

    def entities_dir
      "#{instance_dir}/conf/entities"
    end

    def instance_name
      "#{name}"
    end
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat_instance

    def action_create
      notifying_block do
        create_instance_directories
        create_setenv_file if new_resource.setenv_options
        create_setcron_file if new_resource.setcron_options
        create_web_xml unless config_resource_exist?('web')
        create_server_xml unless config_resource_exist?('server')
        create_context_xml unless config_resource_exist?('context')
      end
      new_resource.bundle_webapps_enabled ? deploy_bundle_wars : undeploy_managed_bundle_wars
    end

    def create_instance_directories
      # Main instance directory
      directory instance_dir do
        owner parent.user
        group parent.group
        mode '0750'
      end

      # Sub-directories
      %w(bin conf lib logs temp webapps work).each do |dir|
        directory "#{instance_dir}/#{dir}" do
          owner parent.user
          group parent.group
          mode '0750'
        end
      end

      directory new_resource.entities_dir do
        owner parent.user
        group parent.group
        mode '0750'
      end
    end

    def create_setenv_file
      file "#{instance_dir}/bin/setenv.sh" do
        content new_resource.setenv_content
        owner parent.user
        group parent.group
        mode '0750'
      end
    end

    def create_setcron_file
      file "/etc/cron.d/#{instance_name}-cleaner.cron" do
        content new_resource.setcron_content
        owner parent.user
        group parent.group
        mode '0750'
      end
    end

    def deploy_bundle_wars
      new_resource.bundle_webapps_enabled.each do |webapp|
        file "#{instance_dir}/webapps/#{webapp}.war" do
          content IO.read("#{parent.catalina_home}/bundle_wars/#{webapp}.war")
          mode '0644'
          owner parent.user
          group parent.group
          action :create
        end
      end
      undeploy_managed_bundle_wars
    end

    def undeploy_managed_bundle_wars
      %w(ROOT docs examples host-manager manager).each do |webapp|
        next if new_resource.bundle_webapps_enabled.include? webapp
        file "#{instance_dir}/webapps/#{webapp}.war" do
          action :delete
        end if new_resource.bundle_webapps_managed.include? webapp
      end
    end

    def config_resource_exist?(type)
      resources = matching_resources(type)

      if resources.length == 1
        Chef::Log.debug(
          "#{log_prefix}: Not creating default #{type} XML. Found '#{resources[0].name}'"
        )
        true
      elsif resources.length > 1
        resource_names = resources.map(&:name)
        Chef::Log.warn(
          "#{log_prefix}: Found multiple #{type} XML resources #{resource_names}"
        )
      else
        Chef::Log.debug(
          "#{log_prefix}: Creating default #{type} XML. No other #{type} XML resource found."
        )
        false
      end
    end

    def matching_resources(type)
      [].tap do |array|
        # Recurse through all contexts if we're in a subcontext
        new_resource.subresources.each do |r|
          array << r if config_match?(r, type)
        end
      end
    end

    def config_match?(resource, type)
      if resource.resource_name == :apache_tomcat_config &&
         resource.name == type
        true
      else
        false
      end
    end

    def log_prefix
      "apache_tomcat_instance[#{new_resource.name}]"
    end

    def instance_dir
      new_resource.instance_dir
    end

    def instance_name
      new_resource.instance_name
    end

    def parent
      new_resource.parent
    end

    class_eval do
      %w(web server context).each do |type|
        define_method "create_#{type}_xml" do
          apache_tomcat_config type do
            # Specifying an instance/parent here is necessary. Otherwise
            # risk auto-discovering the wrong parent.
            instance new_resource.name
            options { include_defaults true }
          end
        end
      end
    end
  end
end
