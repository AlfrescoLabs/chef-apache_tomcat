require 'poise'

module CatalinaConfig
  class Resource < Chef::Resource
    include Poise

    provides :catalina_config
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
              default_source: lazy { "#{type.to_s}.xml.erb" },
              default_options: { include_defaults: true }
  end

  class Provider < Chef::Provider
    include Poise

    provides :catalina_config

    def action_create
      filename = ''
      case new_resource.type
      when :server, :web, :context
        if new_resource.name != new_resource.type.to_s
          Chef::Log.warn("Name should be the same as type when type is :context, :web, or :server")
          Chef::Log.warn("Duplicate resources could exist otherwise.")
        end
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
