#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

catalina 'tomcat'

catalina_instance 'foo' do
  setenv_variables config: [ 'export FOO=bar' ]
end

catalina_config 'web' do
  type :web
  instance 'foo'
  variables(
    servlets: [
      {
        'name'            => 'my_servlet',
        'class'           => 'org.mycompany.MyServlet',
        'init_params'     => { 'debug' => '1', 'listings' => true },
        'load_on_startup' => '1'
      }
    ],
    servlet_mappings: [
      {
        'name'            => 'my_servlet',
        'url-pattern'     => '/', # or an array: ['*.jsp', '*.jspx']
      }
    ],
    filters: [
      {
        'name'            => 'my_filter',
        'class'           => 'org.mycompany.MyFilter',
        'init_params'     => { 'encoding' => 'UTF8', 'max' => '100' },
        'async_supported' => true
      }
    ],
    filter_mappings: [
      {
        'name' => 'my_filter',
        'url_pattern' => '/*', # or an array: ['/pages/*', '/admin/*']
        'dispatcher' => 'REQUEST'
      }
    ],
    session_timeout: 30,
    welcome_file_list: ['index.jsp','index.html']
  )
end

# catalina_service 'foo'
