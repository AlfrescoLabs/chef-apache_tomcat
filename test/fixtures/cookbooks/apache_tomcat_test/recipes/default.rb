#
# Cookbook Name:: apache_tomcat_test
# Recipe:: default
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

apache_tomcat 'tomcat'

apache_tomcat_instance 'instance1'

apache_tomcat_config 'web' do
  type :web
  instance 'instance1'
end

apache_tomcat_config 'server' do
  type :server
  instance 'instance1'
end
