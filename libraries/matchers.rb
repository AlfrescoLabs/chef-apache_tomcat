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

if defined?(ChefSpec)
  ChefSpec.define_matcher :apache_tomcat
  ChefSpec.define_matcher :apache_tomcat_config
  ChefSpec.define_matcher :apache_tomcat_instance
  ChefSpec.define_matcher :apache_tomcat_service

  def install_apache_tomcat(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat, :install, resource_name)
  end

  def uninstall_apache_tomcat(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat, :uninstall, resource_name)
  end

  def create_apache_tomcat_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat_config, :create, resource_name)
  end

  def create_apache_tomcat_instance(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat_instance, :create, resource_name)
  end

  def create_apache_tomcat_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat_service, :create, resource_name)
  end
end
