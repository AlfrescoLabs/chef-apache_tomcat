Manage installation and configuration of Apache Tomcat. Includes
support for multiple instances on a single server as well as flexible management
of XML configuration files.

* Note: This is a work in progress. Documentation and features/stability will
improve before 1.0. Initial release is for testing purposes only. There have 
been some breaking changes in recent releases. This is regrettable, but I believe
it's in the best interest of getting to the best possible user experience in 1.0.
After 1.0, breaking changes will be released as a major version change.

See [Breaking Changes](#breaking-changes) section for important information
for existing users of this cookbook. Specifically, version 0.4.x and 0.5.x have
breaking changes.

# Usage

## Install Apache Catalina Tomcat

This cookbook takes the approach of splitting CATALINA_BASE and CATALINA_HOME.
CATALINA_HOME is the 'shared' location and defaults to `/usr/share/tomcat-<version>`.
CATALINA_BASE represents a particular instance of Tomcat where applications (WARs) 
are deployed. There can be any number of instances per server. CATALINA_BASE
consists of `bin`, `conf`, `lib`, `logs`, `webapps`, `work` and `temp` directories. Configuration
like `server.xml`, `web.xml` go in `conf` and applications are deployed in `webapps` as you
might expect. This not only allows for multiple instances running a single version of Tomcat,
but multiple versions can be installed simultaneously. 

### Complete, basic usage example

To use the resources in this cookbook start by created a dependency in your wrapper
cookbook in `metadata.rb`. 

```
depends 'apache_tomcat'
```

Then, define the resources you need. Resources should be nested to define the 
relationship between Tomcat installation, instance, config resource, etc. 

```ruby
# Install Tomcat 8.0.24 and create 2 independent instances called 'instance1'
# and 'instance2'.
apache_tomcat 'my_tomcat' do

  # Instance will install in `/opt/tomcat/instance1/`
  apache_tomcat_instance 'instance1' do
    apache_tomcat_service 'instance1' 
  end
  
  # Instance will install in `/opt/tomcat/instance2/`
  apache_tomcat_instance 'instance2' do
    apache_tomcat_service 'instance2'
  end  
end
```

The cookbook will try to choose a reasonable default service manager from 
`sysvinit`, `systemd` or `upstart`. However, I recommend using Runit (fully-tested with this cookbook). 
To use Runit, add the following dependencies to your cookbook's `metadata.rb` file. 

Note: runit is pinned to 1.6 because there is currently an issue with runit 1.7
and `poise-service-runit`.

```
depends 'poise-service-runit', '~> 1.0'
depends 'runit', '= 1.6'
```

This will automatically set Runit as the default service provider and
it will work with this cookbook.

# Advanced usage

## Install a different version of Tomcat

By default, this cookbook installs Tomcat version 8.0.24. To install a different
version, specify attributes on the `apache_tomcat` resource.

```ruby
apache_tomcat 'tomcat' do
  url 'http://archive.apache.org/dist/tomcat/...'
  # Note: Checksum is SHA-256, not MD5 or SHA1. Generate using `shasum -a 256 /path/to/tomcat.tar.gz`
  checksum 'sha256_checksum'
  version '8.0.24
  
  # ... apache_tomcat_instance definitions
end  
```

In the basic usage example above, each instance of Tomcat uses the default
`web.xml`, `server.xml`, and `context.xml`. Additionally, no special 
`JAVA_OPTS` or `CATALINA_OPTS` are set in `setenv.sh`. All of this can be customized.

## Set configuration in `setenv.sh`

Each element of the array corresponds to a single line in `setenv.sh`.

```ruby
apache_tomcat 'tomcat' do
  apache_tomcat_instance 'instance1' do
    setenv_options do
      config(
        [
          'export CATALINA_OPTS="',
          '-XX:+UseTLAB -XX:+CMSClassUnloadingEnabled -Xss256k -XX:+UseParNewGC',
          '-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75',
          '-XX:+UseCMSInitiatingOccupancyOnly',
          '-server"'
        ]
      ) 
    end
    
    # ... apache_tomcat_service resource 
  end
end
```

The above configuration yields the following `setenv.sh`

```
export CATALINA_OPTS="
-XX:+UseTLAB -XX:+CMSClassUnloadingEnabled -Xss256k -XX:+UseParNewGC
-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-server"
```

## Create Custom Web XML

```ruby
apache_tomcat 'my_tomcat' do
  apache_tomcat_instance 'instance1' do
    apache_tomcat_config 'web' do
      options do
        # If `true`, this is exactly the same as the default (created automatically
        # by the `apache_tomcat_instance` resource. Set to `false` to specify
        # other parts individually. See `templates/default/web.xml.erb` for
        # more details on the defaults that ship with Tomcat.
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
    
    # ... apache_tomcat_service resource
  end
end
```

The above configuration yield the following web.xml snippet (top XML matter removed
for brevity)

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
apache_tomcat 'my_tomcat' do
  apache_tomcat_instance 'instance1' do
    apache_tomcat_config 'server' do
      options do
        # If `true`, this is exactly the same as the default (created automatically
        # by the `apache_tomcat_instance` resource. Set to `false` to specify
        # other parts individually. See `templates/default/server.xml.erb` for
        # more details on the defaults that ship with Tomcat.
        include_defaults true
        
        # The four settings below, if all set to `true`, are identical
        # to setting `include_default true` above.
        include_default_listeners true
        include_default_user_database true
        include_default_connectors true
        include_default_engine true
        
        server_port 9005
        
        # Define custom listeners to be appended to the default set of listeners
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
      end
    end  
      
    # ... apache_tomcat_service resource  
  end 
end
```

The above configuration yield the following server.xml snippet (top XML matter removed
for brevity)

```xml
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

    <GlobalNamingResources>
      <Resource name="UserDatabase"
                auth="Container"
                type="org.apache.catalina.UserDatabase"
                description="User database that can be updated and saved"
                factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
                pathname="conf/tomcat-users.xml"
                />
    </GlobalNamingResources>

    <Service name="Catalina">
        <Connector port="8080"
                   protocol="HTTP/1.1"
                   connectionTimeout="20000"
                   redirectPort="8443"
                   />
      
        <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />

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

## Additional customization to `server.xml` or `context.xml`

Both `server.xml` and `context.xml` have support for what is called XML entities.
Entities are essentially an 'include' statement that will pull in a small XML
snippet into the larger file. This is a great way to further customize `server.xml`
or `context.xml` without having to fully reconstruct the whole file yourself.

Each file has different inclusion points. 

### `server.xml` entities

The primary purpose of entities within `server.xml` are to define custom 
connectors. Define as many `apache_tomcat_entity` resources within the 
`apache_tomcat_config[server]` resource as you wish. All will be included in 
order.

```ruby
apache_tomcat 'my_tomcat' do
  apache_tomcat_instance 'instance1' do
    apache_tomcat_config 'server' do
      options do
        include_defaults false
        include_default_listeners true
        
        # Set this to false to configure your own connectors via an XML entity.
        include_default_connectors false
        include_default_engine true
      end
     
      # This entity will be created as a separate XML file and the `server.xml`
      # file will automatically include a reference to this file within
      # the <Server> XML portion. This is where connectors belong.
      apache_tomcat_entity 'custom_connector' do
        content(<<EOS
        <Connector port="9090"
                   protocol="HTTP/1.1"
                   connectionTimeout="20000"
                   redirectPort="9443"
                   />        
EOS        
        )
      end
    end 
    
    # ... apache_tomcat_service resource
  end
end       
```

### `context.xml` entities

The default `context.xml` is a very simple file. It consists only of two
'watched resources':

```xml
<Context>
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
    <WatchedResource>${catalina.base}/conf/web.xml</WatchedResource>
</Context>    
```

Beyond this, an entity can be included to set absolutely anything valid in 
`context.xml` that falls between the `<Context>` XML tag.

```ruby
apache_tomcat 'my_tomcat' do
  apache_tomcat_instance 'instance1' do
    apache_tomcat_config 'context' do
      options do
        # Set this to `true` or `false`. If `true`, include the default
        # watched resources. Entity will be included below these resources.
        include_defaults false
      end
        
      apache_tomcat_entity 'custom_context' do
        content("<%-- Any valid context.xml that falls between <Context> tag -->")
      end
    end 
    
    # ... apache_tomcat_service resource
  end
end       
```

## Give me MORE customization

If entities aren't enough and the default `web.xml`, `server.xml` or `context.xml`
do not meet your needs you can choose to define completely custom content or
a template from your wrapper cookbook.

```ruby
apache_tomcat 'my_tomcat' do
  apache_tomcat_instance 'instance1' do
    apache_tomcat_config 'context' do
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
    
    # ... apache_tomcat_service resource
  end
end  
```

## But, I need MOAR customzation

With all due respect, no you don't :smiley: Submit an issue describing your needs
and I will steer you in the right direction. The resources allow for absolutely
*anything* custom to the nth degree. 
 
## Deploying Tomcat Default Bundle Webapps

Tomcat comes with a bundle of default webapps.  These webapps are preserved as
war files in CATALINA_HOME/bundle_wars.  To install these webapps to a tomcat
instance set the `bundle_webapps_enabled` array with the webapps to install.  To
ensure that a webapp is removed after it is removed from `bundle_webapps_enabled`,
add it to the `bundle_webapps_managed` array passed to the instance.  The following
code example will remove `host-manager` and `manager` webapps if they are not included
in the `bundle_webapps_enabled` array, where as the `ROOT` and `docs` webapps will remain installed
if they are not included in the `bundle_webapps_enabled` array.  `ROOT` and `docs` would
have to be removed manually.  If you have a custom webapp that has the same name as
any of the bundle webapps, you will need to make sure that webapp is not included in
`bundle_webapps_enabled` and `bundle_webapps_managed array`, otherwise it may be removed
or overriden by the default bundle webapp.

Tomcat default bundle webapps available for installation: `ROOT, docs, examples, host-manager, manager`

```ruby
apache_tomcat 'tomcat' do
  apache_tomcat_instance 'instance1' do
    bundle_webapps_enabled ['ROOT', 'docs', 'host-manager', 'manager']
    bundle_webapps_managed ['host-manager', 'manager']
    
    # ... apache_tomcat_service resource
  end
end 
```

# Breaking changes

### 0.5.0

Attribute changes in this version were significant. Lots of things moved around
but the trade-off is that defining resources is now easier than ever. Additionally,
other than a minor change in the `config_options` attribute (renamed to remove 
the `config_` prefix) the XML config hash has not changed. All your custom XML 
configuration will still work. If you are left confused after looking at this 
list of breaking changes and reading the usage documentation above, please file 
an issue. I will do my best to resolve your issues.

The following attributes were changed in this version:

#### *`apache_tomcat` resource:*

**Added**:

- `instance_root` - Moved from `prefix_root` on `apache_tomcat_instance`. Defaults
  to `/opt/tomcat`.
- `catalina_home` - Moved from `apache_tomcat_instance`. Defaults to 
  `/usr/share/tomcat-<version>`.

*`apache_tomcat_instance` resource:*

**Removed:**

- `create_default_web_xml`
- `create_default_server_xml`
- `create_default_context_xml`
- `user` - Now inherited from `apache_tomcat`
- `group` - Now inherited from `apache_tomcat`
- `catalina_home` - Now inherited from `apache_tomcat`

#### *`apache_tomcat_config` resource:*

**Removed:**

- `type` Now determined from the resource name: 'server', 'web', 'context'
- `prefix_root` Now automatically obtained from the `apache_tomcat_instance`
- `user` - Now inherited from `apache_tomcat`
- `group` - Now inherited from `apache_tomcat`
- Entity is no longer defined using `apache_tomcat_config`. See new resource `apache_tomcat_entity`.
  
**Changed:**
- `config_*` ( **Renamed**: Rather than `config_options`, `config_content`, or `config_source`, the prefix no longer 
  exists. Simply use `options`, `content`, `source`.
- `options` attribute (formerly `config_options`, see above) no longer accepts `entities` as
  an option key. Entities are automatically determined using resource relationships.

For ease, resources may now be defined in a nested format. See [Usage](#usage) below for nesting details.

### 0.4.0

Runit was previously the service manager used with this cookbook. This version
switches to using poise_service, a pluggable service resource. See
[poise-service](https://github.com/poise/poise-service).

To continue using runit as the service manager, add 'poise-service-runit' and 
'runit' (= 1.6; runit 1.7 is currently not compatible with poise-service-runit) as
a dependency in your wrapper cookbook. This will install and set the runit service
plugin as the default. That's *all* you have to do.

This also has the side-effect of adding proper service-type actions on the 
`apache_tomcat_service` resource. You can now notify the resource for `:restart`,
`:reload`, `:start`, `:stop`, `:enable`, etc.

One final note, when using the poise-service-runit cookbook the log location is 
different than previous versions of this cookbook. Instead of `/var/log/tomcat/<instance>`
logs are now in `/var/log/tomcat-<instance>`. A minor change, but one that makes
sense in my opinion.

If you encounter any other breaking changes not outlined here, please file an
issue. After version 1.0.0 this would have warranted a 2.0.0 (major version) bump.


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
