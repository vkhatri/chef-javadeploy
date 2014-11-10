#
# Cookbook Name:: javadeploy
# Recipe:: java
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

# WARNING:
# User setup by this recipe may not provide a unique
# user/group id across nodes and could create problem
# of non-unique next available user id for User
# management cookbook.
#
# It is advised to use a User management recipe instead
# for Production systems.
#

if node['javadeploy']['install_java']
  # Java attributes to meet minimum requirement.
  # http://lucene.apache.org/solr/4_10_0/SYSTEM_REQUIREMENTS.html
  node.default['java']['jdk_version'] = '7'
  node.default['java']['install_flavor'] = 'oracle'
  node.default['java']['set_default'] = true
  node.default['java']['oracle']['accept_oracle_download_terms'] = true

  include_recipe 'java::default'
end
