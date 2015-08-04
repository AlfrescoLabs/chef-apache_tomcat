#
# Cookbook Name:: apache_tomcat_test
# Spec:: apache_tomcat_instance
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

require 'spec_helper'

describe 'apache_tomcat_test' do
  context 'with default attributes' do
    recipe 'apache_tomcat_test::default'
    step_into :apache_tomcat_config

    context 'in web.xml' do
      [
        '<servlet-name>default</servlet-name>',
        '<session-timeout>30</session-timeout>',
        '<welcome-file>index.html</welcome-file>',
        '<extension>123</extension>'
      ].each do |content|
        it do
          is_expected.to(
            render_file('/opt/tomcat/instance1/conf/web.xml')
              .with_content(content)
          )
        end
      end

      [
        '<filter>',
        '<filter-mapping>'
      ].each do |content|
        it do
          is_expected.not_to(
            render_file('/opt/tomcat/instance1/conf/web.xml')
              .with_content(content)
          )
        end
      end
    end

    context 'in server.xml' do
      [
        '<Server port="8005" shutdown="SHUTDOWN" >',
        '<Listener className="org.apache.catalina.startup.VersionLoggerListener" />',
        '<Resource name="UserDatabase"',
        '<Connector port="8080"',
        '<Engine name="Catalina" defaultHost="localhost">',
        '<Realm className="org.apache.catalina.realm.LockOutRealm">'
      ].each do |content|
        it do
          is_expected.to(
            render_file('/opt/tomcat/instance1/conf/server.xml')
              .with_content(content)
          )
        end
      end
    end
  end

  context 'with custom attributes' do
    recipe 'apache_tomcat_test::custom'
    step_into :apache_tomcat_config

    context 'in web.xml' do
      it do
        is_expected.to(
          render_file('/opt/tomcat/instance1/conf/web.xml')
            .with_content(<<eos
    <servlet>
        <servlet-name>my_servlet1</servlet-name>
        <servlet-class>org.mycompany.MyServlet1</servlet-class>
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
    <servlet>
        <servlet-name>my_servlet2</servlet-name>
        <servlet-class>org.mycompany.MyServlet2</servlet-class>
        <init-param>
            <param-name>debug</param-name>
            <param-value>0</param-value>
        </init-param>
        <init-param>
            <param-name>listings</param-name>
            <param-value>false</param-value>
        </init-param>
        <load-on-startup>2</load-on-startup>
    </servlet>
eos
            )
        )
      end

      it do
        is_expected.to(
          render_file('/opt/tomcat/instance1/conf/web.xml')
            .with_content(<<eos
    <servlet-mapping>
        <servlet-name>my_servlet1</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
    <servlet-mapping>
        <servlet-name>my_servlet2</servlet-name>
        <url-pattern>*.jsp</url-pattern>
        <url-pattern>*.jspx</url-pattern>
    </servlet-mapping>
eos
            )
        )
      end

      it do
        is_expected.to(
          render_file('/opt/tomcat/instance1/conf/web.xml')
            .with_content(<<eos
    <filter>
        <filter-name>my_filter1</filter-name>
        <filter-class>org.mycompany.MyFilter1</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF8</param-value>
        </init-param>
        <init-param>
            <param-name>max</param-name>
            <param-value>200</param-value>
        </init-param>
    </filter>
    <filter>
        <filter-name>my_filter2</filter-name>
        <filter-class>org.mycompany.MyFilter2</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF8</param-value>
        </init-param>
        <init-param>
            <param-name>max</param-name>
            <param-value>200</param-value>
        </init-param>
    </filter>
eos
            )
        )
      end

      it do
        is_expected.to(
          render_file('/opt/tomcat/instance1/conf/web.xml')
            .with_content(<<eos
    <filter-mapping>
        <filter-name>my_filter1</filter-name>
        <url-pattern>/*</url-pattern>
        <dispatcher>REQUEST</dispatcher>
    </filter-mapping>
    <filter-mapping>
        <filter-name>my_filter2</filter-name>
        <url-pattern>/pages/*</url-pattern>
        <url-pattern>/admin/*</url-pattern>
        <dispatcher>REQUEST</dispatcher>
    </filter-mapping>
eos
            )
        )
      end

      it do
        is_expected.to(
          render_file('/opt/tomcat/instance1/conf/web.xml')
            .with_content(<<eos
    <session-config>
        <session-timeout>15</session-timeout>
    </session-config>
eos
            )
        )
      end

      it do
        is_expected.to(
          render_file('/opt/tomcat/instance1/conf/web.xml')
            .with_content(<<eos
    <welcome-file-list>
        <welcome-file>foobar.html</welcome-file>
        <welcome-file>foobar.jsp</welcome-file>
    </welcome-file-list>
eos
            )
        )
      end
    end

    context 'in server.xml' do
      [
        '<Server port="9005" shutdown="SHUTDOWN" >',
        '<Listener className="org.apache.catalina.startup.VersionLoggerListener" />',
        '<Engine name="Catalina" defaultHost="localhost">',
        '<!ENTITY engine-custom SYSTEM "engine-custom.xml">',
        '<Listener className="org.mycompany.MyListener" />',
        '&engine-custom;'
      ].each do |content|
        it do
          is_expected.to(
            render_file('/opt/tomcat/instance1/conf/server.xml')
              .with_content(content)
          )
        end
      end

      it do
        is_expected.to(
          render_file('/opt/tomcat/instance1/conf/server.xml')
            .with_content(<<eos
    <Listener className="org.mycompany.MyComplexListener"
              SSLEngine="on"
              />
eos
            )
        )
      end

      it do
        is_expected.not_to render_file('/opt/tomcat/instance1/conf/server.xml')
          .with_content('<Realm className="org.apache.catalina.realm.LockOutRealm">')
      end
    end
  end
end
