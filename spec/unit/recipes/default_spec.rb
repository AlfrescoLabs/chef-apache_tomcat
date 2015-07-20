#
# Cookbook Name:: tomcat
# Spec:: default
#
# Copyright (c) 2015 Drew A. Blessing, All Rights Reserved.

require 'spec_helper'

describe 'tomcat::default' do
  context 'with default attributes' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5')
        .converge(described_recipe)
    end
    subject { chef_run }

    # Add tests here
  end
end
