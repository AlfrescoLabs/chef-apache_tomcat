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

    provides :apache_tomcat_service

    attribute :instance, kind_of: String, name_attribute: true
    attribute :java_home, kind_of: String, default: '/usr'
    # attribute :catalina_home,
    #           kind_of: String,
    #           default: '/usr/share/tomcat'
    # attribute :catalina_base,
    #           kind_of: String,
    #           default: lazy { "/opt/tomcat/#{instance}" }
    # attribute :user, kind_of: String, default: 'tomcat'
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

    def instance
      resources = run_context.resource_collection.select do |r|
        r.resource_name == :apache_tomcat_instance &&
          r.name ==  new_resource.instance
      end

      if resources.length > 0
        Chef::Log.debug(
          "#{log_prefix}: Using attributes from apache_tomcat_instance[#{new_resource.instance}]"
        )
        @instance_resource = resources.first
      else
        fail(
          NotFoundError,
          "#{log_prefix}: Could not find apache_tomcat_instance[#{new_resource.instance}]"
        )
      end
    end

    def service_options(service)
      service.command(new_resource.command)
      service.directory(instance.catalina_home)
      service.environment(
        CATALINA_HOME: instance.catalina_home,
        CATALINA_BASE: "#{instance.prefix_root}/#{instance.name}",
        JAVA_HOME: new_resource.java_home
      )
      service.user(instance.user)
      service.restart_on_update(new_resource.restart_on_update)
    end
  end
end
