#
# Apache Tomcat Custom Server XML Recipe Example
#
# This is the absolute minimum necessary to create a Tomcat instance

apache_tomcat 'tomcat' do
  url 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.23/bin/apache-tomcat-8.0.23.tar.gz'
  version '8.0.23'
  # This is a SHA2 checksum NOT a SHA1 or MD5. Use `shasum -a 256 /path/to/tomcat.tar.gz`
  checksum '41980bdc3a0bb0abb820aa8ae269938946e219ae2d870f1615d5071564ccecee'
end

# Creates a single instance named 'custom'
# Turns off creation of default xml files
apache_tomcat_instance 'custom' do
  create_default_server_xml false
  create_default_web_xml false
  create_default_context_xml false
end

apache_tomcat_config 'server' do
  type :server
  instance 'custom' # Reference to `apache_tomcat_instance` resource
  config_options do
    include_defaults false # Don't include stock/default configuration
    include_default_listeners true # Most likely you want/need default listeners
    include_default_connectors true # Include http 8080 and ajp 8009
    include_default_engine true # Most likey you want/need the default engine
    # Reference to `apache_tomcat_config[custom_connector]`. Essentially an 'include' statement
    entities ['custom_connector']
  end
end

# Creates a 'custom_connector.xml' file in the instance's conf directory.
apache_tomcat_config 'custom_connector' do
  type :entity
  instance 'custom' # Reference to `apache_tomcat_instance` resource
  # Look for a template file in your wrapper cookbook
  config_source 'custom_connector.erb'
  config_cookbook 'my_wrapper_cookbook'
  # Optionally, pass hash key/values to `config_options` if your custom template
  # needs variables
  config_options do
    custom_variable1 'value1'
    custom_variable2 'value2'
  end
end

# Create a custom web XML with custom servlets and filters
apache_tomcat_config 'web' do
  type :web
  instance 'custom'
  config_options do
    include_defaults false
    include_default_mime_types true
    servlets(
      [
        {
          'name'            => 'my_servlet',
          'class'           => 'org.mycompany.MyServlet',
          'init_params'      => { 'debug' => '1', 'listings' => true },
          'load_on_startup' => '1'
        }
      ]
    )
    servlet_mappings(
      [
        {
          'name'            => 'my_servlet',
          'url_pattern'     => '/', # or an array: ['*.jsp', '*.jspx']
        }
      ]
    )
    filters(
      [
        {
          'name'            => 'my_filter',
          'class'           => 'org.mycompany.MyFilter',
          'init_params'     => { 'encoding' => 'UTF8', 'max' => '100' },
          'async_supported' => true
        }
      ]
    )
    filter_mappings(
      [
        {
          'name' => 'my_filter',
          'url_pattern' => '/*', # or an array: ['/pages/*', '/admin/*']
          'dispatcher' => 'REQUEST'
        }
      ]
    )
  end
end

# Create a 'default' context.xml but include a custom directive.
apache_tomcat_config 'context' do
  type :context
  instance 'custom'
  config_options do
    include_defaults true
    # Reference to `apache_tomcat_config[custom_context]`. Essentially an 'include' statement
    entities ['custom_context']
  end
end

apache_tomcat_config 'custom_context' do
  type :entity
  instance 'custom'
  # Raw content instead of using a template
  config_content(<<EOS
<Manager pathname="" />

<Resource name="jdbc/web" ... />
EOS
  )
end

# Manages the runit service for the 'custom' instance
apache_tomcat_service 'custom'
