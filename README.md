# Description

Manage installation and configuration of Apache Catalina Tomcat. Including
support for multiple instances on a single server as well as flexible management
of XML configuration files.

## Getting Started
If you plan to fork the main cookbook repo please see [forking](#forking) below.

1. Clone this cookbook.
1. Make changes as necessary (be sure to write tests as you go)
1. See [Testing](#testing) below for details on how to run the various tests locally.
1. Commit and push
1. Submit a pull request for review.

## Generating Documentation
DO NOT EDIT THIS README.md file directly. This file is generated using knife-cookbook-doc plugin.
Install this plugin with `gem install knife-cookbook-doc`.
Documentation is compiled from the following sources:

1. Derived for attributes/recipes either by scanning the source code or by explicit declaration
in metadata.rb
1. Markdown files in the doc/ directory (overview is always the first to be compiled)

To edit this README:

1. Change relevant sections within the markdown files in the doc/ directory
1. Edit metadata.rb or use inline annotated comments within the source code.
1. Generate new README using knife-cookbook-doc plugin and push changes to remote branch.

# Usage

## Install Apache Catalina Tomcat

```ruby
catalina 'tomcat' do
  url 'http://archive.apache.org/dist/tomcat/...'
  checksum 'sha256_checksum'
  version '8.0.24
end

# Default version is 8.0.24. To use defaults, simply define:
catalina 'tomcat'
```

## Create an instance

```ruby
catalina_instance 'instance1' do
  setenv_variables config: [ 'export FOO=bar' ]
end
```

## Create Custom Web XML

```ruby
# With defaults
catalina_config 'web' do
  type :web
  instance 'instance1' # Reference to `catalina_instance` resource.
  variables(
    include_default_servlets: true,
    include_default_session_config: true
    include_default_mime_types: true

    # -- or --

    include_defaults: true
  )
end

# Without defaults
catalina_config 'web' do
  type :web
  instance 'instance1'
  variables(
    include_defaults: false,
    include_default_mime_types: true,
    servlets: [
      {
        'name'            => 'my_servlet',
        'class'           => 'org.mycompany.MyServlet',
        'init_params'      => { 'debug' => '1', 'listings' => true },
        'load_on_startup' => '1'
      },
      # ... additional servlets ...
    ],
    servlet_mappings: [
      {
        'name'            => 'my_servlet',
        'url-pattern'     => '/', # or an array: ['*.jsp', '*.jspx']
      },
      # ... additional servlet mappings ...
    ],
    filters: [
      {
        'name'            => 'my_filter',
        'class'           => 'org.mycompany.MyFilter',
        'init_params'     => { 'encoding' => 'UTF8', 'max' => '100' },
        'async_supported' => true
      },
      # ... additional filters ...
    ],
    filter_mappings: [
      {
        'name' => 'my_filter',
        'url_pattern' => '/*', # or an array: ['/pages/*', '/admin/*']
        'dispatcher' => 'REQUEST'
      },
      # ... additional filter_mappings ...
    ],
    session_timeout: 30,
    welcome_file_list: ['index.jsp','index.html']
  )
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

# Requirements

## Platform:

*No platforms defined*

## Cookbooks:

* poise (~> 2.0)
* ark (~> 0.9)
* java (~> 1.31)

# Attributes

*No attributes defined*

# Recipes

* catalina::default

# License and Maintainer

Maintainer:: Drew A. Blessing (<cookbooks@blessing.io>)

License:: all_rights
