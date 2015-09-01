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

# rubocop:disable Metrics/LineLength
describe 'apache_tomcat_instance' do
  context 'with default attributes' do
    recipe 'apache_tomcat_test::default'
    step_into :apache_tomcat_instance

    it { is_expected.to create_directory('/opt/tomcat/instance1').with(user: 'tomcat', group: 'tomcat') }

    %w(bin conf lib logs temp webapps work).each do |dir|
      it { is_expected.to create_directory("/opt/tomcat/instance1/#{dir}").with(user: 'tomcat', group: 'tomcat') }
    end

    it { is_expected.to create_directory('/opt/tomcat/instance1/conf/entities').with(user: 'tomcat', group: 'tomcat') }

    it { is_expected.to create_file('/opt/tomcat/instance1/bin/setenv.sh').with(user: 'tomcat', group: 'tomcat') }
    it { is_expected.to render_file('/opt/tomcat/instance1/bin/setenv.sh').with_content('') }
    it { is_expected.not_to create_file('/opt/tomcat/instance1/conf/web.xml').with(user: 'tomcat', group: 'tomcat') }
  end

  context 'with custom attributes' do
    recipe 'apache_tomcat_test::custom'
    step_into :apache_tomcat_instance

    # it { is_expected.to create_directory('/opt/tomcat').with(user: 'my_tomcat', group: 'my_tomcat') }
    it { is_expected.to create_directory('/opt/tomcat/custom').with(user: 'my_tomcat', group: 'my_tomcat') }

    %w(bin conf lib logs temp webapps work).each do |dir|
      it { is_expected.to create_directory("/opt/tomcat/custom/#{dir}").with(user: 'my_tomcat', group: 'my_tomcat') }
    end

    it { is_expected.to create_directory('/opt/tomcat/custom/conf/entities').with(user: 'my_tomcat', group: 'my_tomcat') }

    it { is_expected.to create_file('/opt/tomcat/custom/bin/setenv.sh').with(user: 'my_tomcat', group: 'my_tomcat') }
    it do
      is_expected.to render_file('/opt/tomcat/custom/bin/setenv.sh')
        .with_content(<<EOS
export CATALINA_OPTS="
-XX:+UseTLAB -XX:+CMSClassUnloadingEnabled -Xss256k -XX:+UseParNewGC
-XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-server"
EOS
)
    end
    it { is_expected.not_to create_file('/opt/tomcat/custom/conf/web.xml').with(user: 'my_tomcat', group: 'my_tomcat') }

    # Custom web and server were defined. Resource with defaults should *not* exist.
    it { is_expected.not_to create_apache_tomcat_config('web').with_options('include_defaults' => true) }
    it { is_expected.not_to create_apache_tomcat_config('server').with_options('include_defaults' => true) }

    # Custom context was not defined. Resource with defaults should exist.
    it { is_expected.to create_apache_tomcat_config('context').with_options('include_defaults' => true) }
  end
end
# rubocop:enable Metrics/LineLength
