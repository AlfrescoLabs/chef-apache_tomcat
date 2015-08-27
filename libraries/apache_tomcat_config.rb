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
          owner instance.user
          group instance.group
          mode '0640'
          content new_resource.config_content
        end
      end
    end

    def instance_config_dir
      "#{instance.prefix_root}/#{instance.name}/conf"
    end

    def instance
      resources = run_context.resource_collection.select do |r|
        r.resource_name == :apache_tomcat_instance &&
          r.name == new_resource.instance
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

    def log_prefix
      "apache_tomcat_config[#{new_resource.name}]"
    end
  end
end
