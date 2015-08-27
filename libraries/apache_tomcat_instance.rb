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

    provides :apache_tomcat_instance
    actions :create

    attribute :name, kind_of: String
    attribute :prefix_root, kind_of: String, default: '/opt/tomcat'
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
    attribute :catalina_home,
              kind_of: String,
              default: '/usr/share/tomcat'
    attribute :setenv,
              option_collector: true,
              template: true,
              default_source: 'setenv.sh.erb'
    attribute :bundle_webapps_enabled,
              kind_of: Array,
              default: []
    attribute :bundle_webapps_managed,
              kind_of: Array,
              default: []
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat_instance

    def action_create
      notifying_block do
        create_instance_directories
        create_setenv_file if new_resource.setenv_options
        create_web_xml if new_resource.create_default_web_xml
        create_server_xml if new_resource.create_default_server_xml
        create_context_xml if new_resource.create_default_context_xml
      end
      new_resource.bundle_webapps_enabled ? deploy_bundle_wars : undeploy_managed_bundle_wars
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

    def deploy_bundle_wars
      new_resource.bundle_webapps_enabled.each do |webapp|
        file "#{instance_dir}/webapps/#{webapp}.war" do
          content IO.read("#{new_resource.catalina_home}/bundle_wars/#{webapp}.war")
          mode '0644'
          owner new_resource.user
          group new_resource.group
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
      resources = run_context.resource_collection.select do |r|
        r.resource_name == :apache_tomcat_config && r.type == type && r.instance == new_resource.name
      end

      if resources.length == 1
        Chef::Log.debug("#{log_prefix}: Not creating default #{type} XML. Found '#{resources[0].name}'")
        true
      elsif resources.length > 1
        resource_names = resources.map { |r| r.name }
        Chef::Log.warn("#{log_prefix}: Found multiple #{type} XML resources #{resource_names}")
      else
        Chef::Log.debug("#{log_prefix}: Creating default #{type} XML. No other #{type} XML resource found.")
        false
      end
    end

    def log_prefix
      "apache_tomcat_instance[#{new_resource.name}]"
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
