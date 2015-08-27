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

    provides :apache_tomcat_config
    actions :create

    attribute :name, kind_of: String
    attribute :type,
              equal_to: [:server, :web, :context, :entity],
              required: true
    attribute :instance, kind_of: String, required: true
    attribute :prefix_root, kind_of: String, default: '/opt/tomcat'
    attribute :user, kind_of: String, default: 'tomcat'
    attribute :group, kind_of: String, default: 'tomcat'
    attribute :config,
              option_collector: true,
              template: true,
              default_source: lazy { default_source_check },
              default_options: { include_defaults: true }

    def default_source_check
      if type == :entity && ((!config_source && !config_cookbook) || !config_content)
        fail Chef::Exceptions::ValidationFailed,
             'when config \'type\' is \':entity\', \'config_content\' or '\
             '\'config_source\' and \'config_cookbook\' must be specified'
      end
      "#{type}.xml.erb"
    end
  end

  class Provider < Chef::Provider
    include Poise

    provides :apache_tomcat_config

    def action_create
      filename = ''
      case new_resource.type
      when :server, :web, :context
        filename = new_resource.type.to_s
      when :entity
        filename = new_resource.name.to_s
      end
      notifying_block do
        file "#{instance_config_dir}/#{filename}.xml" do
          owner new_resource.user
          group new_resource.group
          mode '0640'
          content new_resource.config_content
        end
      end
    end

    def instance_config_dir
      "#{new_resource.prefix_root}/#{new_resource.instance}/conf"
    end
  end
end
