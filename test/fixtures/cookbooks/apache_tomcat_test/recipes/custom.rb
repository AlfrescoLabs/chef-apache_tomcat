#
# Cookbook Name:: apache_tomcat_test
# Recipe:: custom
#
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
        }
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
        }
      ]
    )
    session_timeout 15
    welcome_file_list ['foobar.html', 'foobar.jsp']
  end
end

apache_tomcat_config 'server' do
  type :server
  instance 'instance1'
  config_options do
    include_defaults false
    include_default_listeners true
    include_default_engine true
    server_port 9005
    listeners(
      [
        'org.mycompany.MyListener',
        {
          'class_name'  => 'org.mycompany.MyComplexListener',
          'params'      => { 'SSLEngine' => 'on' }
        }
      ]
    )
    entities(
      [
        #{ 'connector-http-9080' => 'connector-http-9080.xml' },
        'engine-custom'
      ]
    )
  end
end
