#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

catalina 'tomcat'

catalina_instance 'foo' do
  setenv_variables config: [ 'export FOO=bar' ]
end

catalina_config 'server' do
  type :server
  instance 'foo'
  variables(
    include_defaults: false,
    include_default_listeners: true,
    include_default_engine: true,
    server_port: 9005,
    listeners: [
      'org.mycompany.MyListener',
      {
        'class_name'  => 'org.mycompany.MyComplexListener',
        'params'      => { 'SSLEngine' => 'on' }
      },
    ],
    entities: {
      'connector-http-9080' => 'connector-http-9080.xml',
      'engine-custom'       => 'engine-custom.xml',
    }
  )
end

# catalina_service 'foo'
