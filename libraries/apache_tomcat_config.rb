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

module ApacheTomcatConfig
  class Resource < Chef::Resource
    include Poise

    # Sets this resource as a subresource container.
    # `false` means not to namespace the resources
    poise_subresource_container false

    # This resource is also a subresource of `apache_tomcat_instance`
    poise_subresource :apache_tomcat_instance

    provides :apache_tomcat_config
    actions :create

    attribute :name, equal_to: %w(server web context)
    # Empty name means no prefix on poise methods: `options`, `content`, `cookbook`
    # instead of `config_options`, etc.
    attribute '',
              template: true,
              default_source: lazy { "#{name}.xml.erb" },
              default_options: lazy { merge_options }

    # When defined un-nested, user must set the parent. `instance` is a little better term for users
    # who may not know or care what a parent/subresource is.
    alias_method :instance, :parent

    def merge_options
      if name == 'web'
        Chef::Log.warn(
          'apache_tomcat_config[web]: web.xml does not accept ' \
          'entities. Use a custom web.xml instead.'
        )
      end

      {
        include_defaults: true,
        entities: subresources.map(&:namespaced_name),
        entities_dir: parent.entities_dir
      }
    end
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat_config

    def action_create
      notifying_block do
        file "#{instance_config_dir}/#{new_resource.name}.xml" do
          owner grandparent.user
          group grandparent.group
          mode '0640'
          content new_resource.content
        end
      end
    end

    def instance_config_dir
      "#{parent.instance_dir}/conf"
    end

    def parent
      new_resource.parent
    end

    def grandparent
      new_resource.parent.parent
    end
  end
end
