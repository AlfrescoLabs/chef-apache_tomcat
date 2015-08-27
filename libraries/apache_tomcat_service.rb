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

require 'poise_service/service_mixin'

module ApacheTomcatService
  class Resource < Chef::Resource
    include PoiseService::ServiceMixin
    poise_subresource :apache_tomcat_instance

    provides :apache_tomcat_service

    attribute :instance, kind_of: String, name_attribute: true
    attribute :java_home, kind_of: String, default: '/usr'
    attribute :restart_on_update, kind_of: [TrueClass, FalseClass], default: true

    def service_name
      "tomcat-#{instance}"
    end

    def command
      'bin/catalina.sh run'
    end
  end

  class Provider < Chef::Provider
    include PoiseService::ServiceMixin

    provides :apache_tomcat_service

    def service_options(service)
      service.command(new_resource.command)
      service.directory(grandparent.catalina_home)
      service.environment(
        CATALINA_HOME: grandparent.catalina_home,
        CATALINA_BASE: parent.instance_dir,
        JAVA_HOME: new_resource.java_home
      )
      service.user(grandparent.user)
      service.restart_on_update(new_resource.restart_on_update)
    end

    def parent
      new_resource.parent
    end

    def grandparent
      new_resource.parent.parent
    end
  end
end
