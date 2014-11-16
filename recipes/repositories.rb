#
# Cookbook Name:: javadeploy
# Recipe:: repositories
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

unless node['javadeploy']['repositories'].empty?
  databag = data_bag_item(node['javadeploy']['databag'], 'repositories')['repositories']
  puts "\n\n #{databag.inspect} \n\n"

  node['javadeploy']['repositories'].each do |repo_name, repo_options|
    fail "unable to find repository '#{repo_name}' details in data bag '#{node['javadeploy']['databag']}' item 'repositories'" unless databag.key?(repo_name)
    repo_details = databag[repo_name]
    javadeploy repo_name do
      args repo_details['args']
      auto_java_xmx repo_details['auto_java_xmx']
      class_name repo_details['class_name']
      class_path repo_details['class_path']
      console_log repo_details['console_log']
      cookbook repo_details['cookbook']
      current_revision repo_details['current_revision']
      databag_revision repo_details['databag_revision']
      dir_mode repo_details['dir_mode']
      environment repo_details['environment']
      ext_class_path repo_details['ext_class_path']
      file_revision repo_details['file_revision']
      flock repo_details['flock']
      group repo_details['group']
      init_style repo_details['init_style']
      jar repo_details['jar']
      manage_service repo_details['manage_service']
      notify_restart repo_details['notify_restart']
      options repo_details['options']
      other_revisions repo_details['other_revisions']
      purge repo_details['purge']
      repository_checkout repo_details['repository_checkout']
      repository_url repo_details['repository_url']
      revision_service_notify_action repo_details['revision_service_notify_action']
      revision_service_notify_timing repo_details['revision_service_notify_timing']
      service_action repo_details['service_action']
      service_name repo_details['service_name']
      service_supports repo_details['service_supports']
      ssh_key_wrapper_file repo_details['ssh_key_wrapper_file']
      user repo_details['user']
      verify_file repo_details['verify_file']
      action repo_options['action'] || :create
    end
  end
end
