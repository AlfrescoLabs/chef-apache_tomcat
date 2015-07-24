#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

apache_tomcat 'tomcat'

apache_tomcat_instance 'foo'

# apache_tomcat_config 'connector-9080' do
#   type :entity
#   instance 'foo'
#   config_content 'foo'
# end
#
# apache_tomcat_config 'server' do
#   type :server
#   instance 'foo'
#   config_options do
#     include_defaults false
#     include_default_listeners true
#     include_default_engine true
#     server_port 9005
#     entities ['connector-9080']
#   end
# end

apache_tomcat_service 'foo'
