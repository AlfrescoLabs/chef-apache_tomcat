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

module ApacheTomcatEntity
  class Resource < Chef::Resource
    include Poise
    poise_subresource :apache_tomcat_config

    provides :apache_tomcat_entity
    actions :create

    attribute :name, kind_of: String
    attribute '', template: true

    # Namespace the entity to prevent collisions in files
    def namespaced_name
      "#{parent.name}-#{name}"
    end
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat_entity

    def action_create
      # TODO: Fail if parent is 'web'?
      notifying_block do
        file "#{instance.entities_dir}/#{new_resource.namespaced_name}.xml" do
          owner great_grandparent.user
          group great_grandparent.group
          mode '0640'
          content new_resource.content
        end
      end
    end

    # apache_tomcat_config
    def parent
      new_resource.parent
    end

    # apache_tomcat_instance
    def grandparent
      parent.parent
    end
    alias_method :instance, :grandparent

    # apache_tomcat
    def great_grandparent
      grandparent.parent
    end
  end
end
