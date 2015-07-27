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
