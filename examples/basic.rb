#
# Apache Tomcat Basic Recipe Example
#
# This is the absolute minimum necessary to create a Tomcat instance

# Installs Tomcat 8.0.24
apache_tomcat 'tomcat'

# Creates a single instance named 'basic'
# By default, this resource also creates a stock server.xml, web.xml and context.xml
apache_tomcat_instance 'basic'

# Manages the runit service for the 'basic' instance
apache_tomcat_service 'basic'
