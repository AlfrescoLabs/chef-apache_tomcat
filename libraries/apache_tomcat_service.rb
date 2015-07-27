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

module ApacheTomcatService
  class Resource < Chef::Resource
    include Poise

    provides :apache_tomcat_service
    actions :create

    attribute :instance, kind_of: String, name_attribute: true
    attribute :java_home, kind_of: String, default: '/usr'
    attribute :catalina_home,
              kind_of: String,
              default: '/usr/share/tomcat'
    attribute :catalina_base,
              kind_of: String,
              default: lazy { "/opt/tomcat/#{instance}" }
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
    attribute :log_dir, kind_of: String, default: '/var/log/tomcat'
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat_service

    def action_create
      notifying_block do
        include_recipe 'runit'

        directory new_resource.log_dir do
          recursive true
          owner new_resource.user
          group new_resource.group
          mode '0770'
        end

        directory "#{new_resource.log_dir}/#{new_resource.instance}" do
          owner new_resource.user
          group new_resource.group
          mode '0770'
        end

        runit_service "tomcat-#{new_resource.instance}" do
          owner new_resource.user
          group new_resource.group
          run_template_name 'tomcat'
          log_template_name 'tomcat'
          cookbook 'apache_tomcat'
          options(
            name: new_resource.instance,
            catalina_home: new_resource.catalina_home,
            catalina_base: new_resource.catalina_base,
            java_home: new_resource.java_home,
            user: new_resource.user
          )
        end
      end
    end
  end
end
