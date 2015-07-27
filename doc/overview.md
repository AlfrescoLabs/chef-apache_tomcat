Manage installation and configuration of Apache Tomcat. Includes
support for multiple instances on a single server as well as flexible management
of XML configuration files.

* Note: This is a work in progress. Documentation and features/stability will
improve before 1.0. Initial release is for testing purposes only.

# Usage

## Install Apache Catalina Tomcat

This cookbook takes the approach of splitting CATALINA_BASE and CATALINA_HOME.
CATALINA_HOME is the 'shared' location and defaults to /usr/share/tomcat-<version>.
CATALINA_BASE represents a particular instance of Tomcat where applications (WARs) 
are deployed. There can be any number of instances per server. CATALINA_BASE
consists of bin, conf, lib, logs, webapps, work and temp directories. Configuration
like server.xml, web.xml go in conf and applications are deployed in webapps as you
might expect.

```ruby
apache_tomcat 'my_tomcat' do
  url 'http://archive.apache.org/dist/tomcat/...'
  # Note: Checksum is SHA-256, not MD5 or SHA1. Generate using `shasum -a 256 /path/to/tomcat.tar.gz`
  checksum 'sha256_checksum'
  version '8.0.24
end

# Default version is 8.0.24. To use defaults, simply define:
apache_tomcat 'my_tomcat'
```

## Create an instance

For a basic instance, define as seen below. Please note that this will create
a default web.xml, server.xml and context.xml. This will likely meet most
user's needs. However, if you need custom configuration for any of these files
set the corresponding attribute to `false`.

```ruby
apache_tomcat_instance 'instance1'

# Non-default attributes
apache_tomcat_instance 'instance1' do
  setenv_options(config: ['export CATALINA_OPTS=foo'])
  include_default_server_xml false
  include_default_web_xml false
  include_default_context_xml false
end
```

## Create Custom Web XML

If `include_default_web_xml` is set to false on the instance resource you will
need to define a config resource to build a custom web.xml file.

```ruby
# Default attributes
# Note: The definition below will result in an identical web.xml as when created
# by the instance resource with `include_default_web_xml true`.
apache_tomcat_config 'web' do
  type :web
  instance 'instance1' # Reference to `apache_tomcat_instance` resource. 
end

# Non-default attributes

## First, disable default web.xml creation in the instance
apache_tomcat_instance 'instance1' do
  ...
  create_default_web_xml false
end

apache_tomcat_config 'web' do
  type :web
  instance 'instance1'
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
        },
        # ... additional servlets ...
      ]
    )
    servlet_mappings(
      [
        {
          'name'            => 'my_servlet',
          'url_pattern'     => '/', # or an array: ['*.jsp', '*.jspx']
        },
        # ... additional servlet mappings ...
      ]
    )
    filters(
      [
        {
          'name'            => 'my_filter',
          'class'           => 'org.mycompany.MyFilter',
          'init_params'     => { 'encoding' => 'UTF8', 'max' => '100' },
          'async_supported' => true
        },
        # ... additional filters ...
      ]
    )
    filter_mappings(
      [
        {
          'name' => 'my_filter',
          'url_pattern' => '/*', # or an array: ['/pages/*', '/admin/*']
          'dispatcher' => 'REQUEST' 
        },
        # ... additional filter_mappings ...
      ]
    )
    session_timeout 30
    welcome_file_list ['index.jsp','index.html']
  end
end
```

## The above configuration yield the following web.xml:
```xml
    <servlet>
        <servlet-name>my_servlet</servlet-name>
        <servlet-class>org.mycompany.MyServlet</servlet-class>
        <init-param>
            <param-name>debug</param-name>
            <param-value>1</param-value>
        </init-param>
        <init-param>
            <param-name>listings</param-name>
            <param-value>true</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>my_servlet</servlet-name>
    </servlet-mapping>

    <filter>
        <filter-name>my_filter</filter-name>
        <filter-class>org.mycompany.MyFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF8</param-value>
        </init-param>
        <init-param>
            <param-name>max</param-name>
            <param-value>100</param-value>
        </init-param>
    </filter>

    <filter-mapping>
        <filter-name>my_filter</filter-name>
        <url-pattern>/*</url-pattern>
        <dispatcher>REQUEST</dispatcher>
    </filter-mapping>

    <session-config>
        <session-timeout>30</session-timeout>
    </session-config>

    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
        <welcome-file>index.html</welcome-file>
    </welcome-file-list>
    
    <mime-mapping>
        <extension>123</extension>
        <mime-type>application/vnd.lotus-1-2-3</mime-type>
    </mime-mapping>
    <!-- ... all of the mime-mappings ... -->
```

## Create Custom Server XML

```ruby
## First, disable default server.xml creation in the instance
apache_tomcat_instance 'instance1' do
  ...
  create_default_server_xml false
end

# With defaults
apache_tomcat_config 'server' do
  type :server
  instance 'instance1' # Reference to `apache_tomcat_instance` resource.
  config_options do
    include_default_listeners true
    include_default_user_database true
    include_default_connectors true
    include_default_engine true
    
    # -- or --
    
    include_defaults true
  end 
end

# Non-default attributes

## First, disable default web.xml creation in the instance
apache_tomcat_instance 'instance1` do
  ...
  create_default_server_xml false
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
        },
        ... additional listeners ...
      ]
    )
    entities [ 'connector-http-9080', 'engine-custom' ]
  end 
```

## The above configuration yield the following server.xml:
```xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE server-xml [
  <!ENTITY connector-http-9080 SYSTEM "connector-http-9080.xml">
  <!ENTITY engine-custom SYSTEM "engine-custom.xml">
]>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance withs
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<Server port="9005" shutdown="SHUTDOWN" >
    <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
    <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
    <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
    <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
    <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
    <Listener className="org.mycompany.MyListener" />
    <Listener className="org.mycompany.MyComplexListener"
              SSLEngine="on"
              />

    <Service name="Catalina">
        &connector-http-9080;
        &engine-custom;

        <Engine name="Catalina" defaultHost="localhost">
            <Realm className="org.apache.catalina.realm.LockOutRealm">
                <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
                       resourceName="UserDatabase"
                       />
            </Realm>

            <Host name="localhost"
                  appBase="webapps"
                  unpackWARs="true"
                  autoDeploy="true"
                  />

        </Engine>
    </Service>
</Server>
```

# Testing

## Code Style
To run style tests (Rubocop and Foodcritic):
`rake style`

If you want to run either Rubocop or Foodcritic separately, specify the style
test type (Rubocop = ruby, Foodcritic = chef)
`rake style:chef`
or
`rake style:ruby`

## RSpec tests
Run RSpec unit tests
`rake spec`

## Test Kitchen
Run Test Kitchen tests (these tests take quite a bit of time)
`rake integration:vagrant`

If the cookbook has tests that run in EC2
`rake integration:cloud`

# Forking

If you choose to fork this cookbook here are some good tips to keep things in
order

1. Fork the cookbook *before* cloning.
1. Clone the *forked* repo, not the original.
1. Once the fork is cloned, go to the repo directory and add an `upstream`
remote
`git remote add upstream git@gitlab.example.com:cookbooks/this_cookbook.git`

Now you can pull `upstream` changes (things merged into the main cookbook repo).
Note that you will also need to push to your fork's master to keep it updated.
The alias below will help you. After adding the alias you will simply be able to
run `git-reup` and it will pull the upstream changes and push them to
your fork. Then checkout a branch and work as normal.

Add the following alias in `~/.bash_profile`.
`alias git-reup='git checkout master && git pull upstream master && git push origin master'`
