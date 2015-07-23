require 'chefspec'
require 'chefspec/berkshelf'
require 'halite/spec_helper'
require_relative '../libraries/apache_tomcat'
require_relative '../libraries/apache_tomcat_config'
require_relative '../libraries/apache_tomcat_instance'
require_relative '../libraries/apache_tomcat_service'

RSpec.configure do |config|
  config.include Halite::SpecHelper
end
