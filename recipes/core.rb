#
# Cookbook Name:: javadeploy
# Recipe:: core
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

[node['javadeploy']['base_dir'],
 node['javadeploy']['repositories_dir'],
 node['javadeploy']['log_dir'],
 node['javadeploy']['ssh_key_wrapper_dir']
].each do |dir|
  directory dir do
    owner node['javadeploy']['user']
    group node['javadeploy']['group']
    mode node['javadeploy']['dir_mode']
  end
end

if node['javadeploy']['setup_ulimit']
  # javadeploy service user limits
  user_ulimit node['javadeploy']['user'] do
    filehandle_limit node['javadeploy']['limits']['nofile']
    process_limit node['javadeploy']['limits']['nproc']
    memory_limit node['javadeploy']['limits']['memlock']
  end

  pam_limits = 'session    required   pam_limits.so'
  ruby_block 'require_pam_limits.so' do
    block do
      fe = Chef::Util::FileEdit.new('/etc/pam.d/su')
      fe.search_file_replace_line(/# #{pam_limits}/, pam_limits)
      fe.write_file
    end
    only_if { ::File.readlines('/etc/pam.d/su').grep(/# #{pam_limits}/).any? }
  end
end
