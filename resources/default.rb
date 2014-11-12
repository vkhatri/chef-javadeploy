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

attribute :service_name,      :kind_of => String, :default => nil
attribute :manage_service,    :kind_of => String, :default => node['javadeploy']['manage_service']
attribute :service_action,    :kind_of => String, :default => %w(start enable)
attribute :service_supports,  :kind_of => Array, :default => { :status => true, :start => true, :stop => true, :restart => true }

attribute :user,    :kind_of => String, :default => node['javadeploy']['user']
attribute :group,   :kind_of => String, :default => node['javadeploy']['group']
attribute :init_style,      :kind_of => String, :default => node['javadeploy']['init_style']

attribute :repository_url,      :kind_of => String, :required => true, :default => nil
attribute :repository_action,      :kind_of => String, :default => node['javadeploy']['checkout_action']

attribute :ssh_key_wrapper_file,  :kind_of => String, :default => nil

attribute :console_log,     :kind_of => [TrueClass, FalseClass], :default => true

attribute :verify_file,     :kind_of => String, :default => nil

attribute :class_path,      :kind_of => Array,  :default => []
attribute :ext_class_path,  :kind_of => Array, :default => []
attribute :class_name,      :kind_of => String, :default => nil
attribute :options,         :kind_of => Array,  :default => node['javadeploy']['java_options']
attribute :jar,             :kind_of => String, :default => nil
attribute :args,            :kind_of => Array,  :default => []
attribute :auto_java_xmx,    :kind_of => [TrueClass, FalseClass],  :default => node['javadeploy']['set_java_xmx']

attribute :verify_file,     :kind_of => String, :default => nil

attribute :other_revisions, :kind_of => Array, :default => []
attribute :current_revision,    :kind_of => String, :default => node['javadeploy']['current_revision']
attribute :databag_revision,    :kind_of => [TrueClass, FalseClass], :default => node['javadeploy']['databag_revision']
attribute :file_revision,       :kind_of => String, :default => node['javadeploy']['file_revision']

attribute :pre_include_recipe,    :kind_of => Array, :default => []
attribute :post_include_recipe,    :kind_of => Array, :default => []

attribute :cookbook,            :kind_of => String, :default => 'javadeploy'
attribute :notify_restart,      :kind_of => String, :default => nil
attribute :purge,               :kind_of => String, :default => node['javadeploy']['purge']
attribute :dir_mode,               :kind_of => String, :default => node['javadeploy']['dir_mode']
