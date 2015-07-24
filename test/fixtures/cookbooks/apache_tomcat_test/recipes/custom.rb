#
# Cookbook Name:: apache_tomcat_test
# Recipe:: custom
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

apache_tomcat 'tomcat'

apache_tomcat_instance 'instance1'

apache_tomcat_config 'web' do
  type :web
  instance 'instance1'
  config_options do
    include_defaults false
    include_default_mime_types true
    servlets(
      [
        {
          'name'            => 'my_servlet1',
          'class'           => 'org.mycompany.MyServlet1',
          'init_params'      => { 'debug' => '1', 'listings' => true },
          'load_on_startup' => '1'
        },
        {
          'name'            => 'my_servlet2',
          'class'           => 'org.mycompany.MyServlet2',
          'init_params'      => { 'debug' => '0', 'listings' => false },
          'load_on_startup' => '2'
        }
      ]
    )
    servlet_mappings(
      [
        {
          'name'            => 'my_servlet1',
          'url_pattern'     => '/', # or an array: ['*.jsp', '*.jspx']
        },
        {
          'name'            => 'my_servlet2',
          'url_pattern'     =>  ['*.jsp', '*.jspx']
        },
      ]
    )
    filters(
      [
        {
          'name'            => 'my_filter1',
          'class'           => 'org.mycompany.MyFilter1',
          'init_params'     => { 'encoding' => 'UTF8', 'max' => '200' },
          'async_supported' => true
        },
        {
          'name'            => 'my_filter2',
          'class'           => 'org.mycompany.MyFilter2',
          'init_params'     => { 'encoding' => 'UTF8', 'max' => '200' },
          'async_supported' => false
        }
      ]
    )
    filter_mappings(
      [
        {
          'name' => 'my_filter1',
          'url_pattern' => '/*', # or an array: ['/pages/*', '/admin/*']
          'dispatcher' => 'REQUEST'
        },
        {
          'name' => 'my_filter2',
          'url_pattern' => ['/pages/*', '/admin/*'],
          'dispatcher' => 'REQUEST'
        },
      ]
    )
    session_timeout 15
    welcome_file_list ['foobar.html','foobar.jsp']
  end
end
