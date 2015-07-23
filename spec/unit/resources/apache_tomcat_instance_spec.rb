#
# Cookbook Name:: apache_tomcat_test
# Spec:: apache_tomcat_instance
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

require 'spec_helper'

describe 'apache_tomcat_test::default' do
  context 'with default attributes' do
    recipe 'apache_tomcat_test::default'
    step_into :apache_tomcat_instance

    it { is_expected.to create_directory('/opt/tomcat') }
  end
end
