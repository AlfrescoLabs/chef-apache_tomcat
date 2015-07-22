#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

catalina 'tomcat'

catalina_instance 'foo' do
  setenv_options config: [ 'export FOO=bar' ]
  create_default_web_xml true
  create_default_server_xml true
end

# catalina_config 'web' do
#   type :web
#   instance 'foo'
#   config_options do
#     include_defaults false
#     include_default_mime_types true
#     servlets([
#                {
#                  'name'            => 'my_servlet',
#                  'class'           => 'org.mycompany.MyServlet',
#                  'init_params'      => { 'debug' => '1', 'listings' => true },
#                  'load_on_startup' => '1'
#                },
#              ... additional servlets ...
             # ])
    # servlet_mappings([
    #                    {
    #                      'name'            => 'my_servlet',
    #                      'url-pattern'     => '/', # or an array: ['*.jsp', '*.jspx']
    #                    },
    #                  ... additional servlet mappings ...
                     # ])
    # filters([
    #           {
    #             'name'            => 'my_filter',
    #             'class'           => 'org.mycompany.MyFilter',
    #             'init_params'     => { 'encoding' => 'UTF8', 'max' => '100' },
    #             'async_supported' => true
    #           },
    #         ... additional filters ...
            # ])
    # filter_mappings([
    #                   {
    #                     'name' => 'my_filter',
    #                     'url_pattern' => '/*', # or an array: ['/pages/*', '/admin/*']
    #                     'dispatcher' => 'REQUEST'
    #                   },
    #                 ... additional filter_mappings ...
                    # ])
    # session_timeout 30
    # welcome_file_list ['index.jsp','index.html']
  # end
  # config_options do
  #   include_defaults false
  #   include_default_listeners true
  #   include_default_engine true
  #   server_port 9005
  #   listeners([
  #     'org.mycompany.MyListener',
  #     {
  #       'class_name'  => 'org.mycompany.MyComplexListener',
  #       'params'      => { 'SSLEngine' => 'on' }
  #     }
  #   ])
  #   entities(
  #     'connector-http-9080' => 'connector-http-9080.xml',
  #     'engine-custom'       => 'engine-custom.xml'
  #   )
  # end
# end

# catalina_service 'foo'
