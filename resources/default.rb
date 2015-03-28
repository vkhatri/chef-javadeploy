#
# Cookbook Name:: javadeploy
# Resource:: default
#
# Copyright 2014, Virender Khatri
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
#

actions :create, :delete

default_action :create

attribute :repository_url,      :kind_of => String, :default => nil
attribute :repository_depth,    :kind_of => Integer, :default => nil
attribute :repository_checkout, :kind_of => String, :default => node['javadeploy']['repository_checkout']

attribute :migrate, :kind_of => [TrueClass, FalseClass], :default => node['javadeploy']['migrate']
attribute :user,    :kind_of => String, :default => node['javadeploy']['user']
attribute :group,   :kind_of => String, :default => node['javadeploy']['group']
attribute :dir_mode,        :kind_of => String, :default => node['javadeploy']['dir_mode']

attribute :service_name,      :kind_of => String, :default => nil
attribute :manage_service,    :kind_of => String, :default => node['javadeploy']['manage_service']
attribute :service_action,    :kind_of => [String, Array], :default => node['javadeploy']['service_action']
attribute :service_supports,  :kind_of => Array, :default => node['javadeploy']['service_supports']
attribute :init_style,      :kind_of => String, :default => node['javadeploy']['init_style']

attribute :ssh_key_wrapper_file,  :kind_of => String, :default => nil
attribute :console_log,     :kind_of => [TrueClass, FalseClass], :default => node['javadeploy']['console_log']
attribute :verify_file,     :kind_of => String, :default => node['javadeploy']['verify_file']

attribute :class_path,      :kind_of => Array,  :default => node['javadeploy']['class_path']
attribute :ext_class_path,  :kind_of => Array, :default => node['javadeploy']['ext_class_path']
attribute :class_name,      :kind_of => String, :default => node['javadeploy']['class_name']
attribute :options,         :kind_of => Array,  :default => node['javadeploy']['java_options']
attribute :jar,             :kind_of => String, :default => node['javadeploy']['jar']
attribute :args,            :kind_of => Array,  :default => node['javadeploy']['args']
attribute :auto_java_xmx,   :kind_of => [TrueClass, FalseClass],  :default => node['javadeploy']['set_java_xmx']

# environment for data bag revision, defaults to node chef_environment
# making environment optional goes against the point, but could
# be very useful in some scenarios and testing
attribute :environment, :kind_of => String, :default => node.environment

# node cluster / flock attribute, this could differ one setup to another, hence
# optional to configure used node cluster attribute
attribute :flock, :kind_of => String, :default => node[node['javadeploy']['flock_attribute']]

attribute :other_revisions,   :kind_of => Array, :default => nil
attribute :current_revision,  :kind_of => String, :default => node['javadeploy']['current_revision']
attribute :databag_revision,  :kind_of => [TrueClass, FalseClass], :default => node['javadeploy']['databag_revision']
attribute :file_revision,     :kind_of => [FalseClass, String], :default => node['javadeploy']['file_revision']

attribute :notify_restart,  :kind_of => String, :default => node['javadeploy']['notify_restart']
attribute :revision_service_notify_action,      :kind_of => String, :default => node['javadeploy']['revision_service_notify_action']
attribute :revision_service_notify_timing,      :kind_of => String, :default => node['javadeploy']['revision_service_notify_timing']

attribute :cookbook,        :kind_of => String, :default => 'javadeploy'

attribute :purge,           :kind_of => String, :default => node['javadeploy']['purge']
