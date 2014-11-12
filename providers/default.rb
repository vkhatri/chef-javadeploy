#
# Cookbook Name:: javadeploy
# Provider:: default
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

def whyrun_supported?
  true
end

action :create do
  new_resource.updated_by_last_action(repository)
end

action :delete do
  new_resource.updated_by_last_action(repository)
end

protected

def current_revision(repository)
  databag_revision(repository, 'current_revision')
end

def other_revisions(repository)
  databag_revision(repository, 'other_revisions')
end

def databag_revision(repository, type)
  revision = databag_revision_find(repository, type, 'fqdn')
  unless revision
    revision = databag_revision_find(repository, type, 'flock')
    unless revision
      revision = databag_revision_find(repository, type, 'environment')
      unless revision
        revision = databag_revision_find(repository, type, 'default')
      end
    end
  end
  revision
end

def databag_revision_find(repository, type, level)
  #
  # different databag items:
  #   Each level / hierarchy is actually an item of the
  #   databag with a perfix - 'revision'.
  #
  #   You must create below data bag items for revisions override
  #   hierarchy:
  #
  #   - revision_fqdn
  #   - revision_flock
  #   - revision_environment
  #   - revision_default
  #
  # databag item attribute:
  #   Each data bag item must have an attribute - 'repositories' which
  #   will have the repositories with only two attributes:
  #
  #   - current_revision
  #   - other_revisions
  #
  # how a repository revision search happens in databag / items:
  #   {databag name} / {level | hierarchy item name} / 'repositories' / {repository_name} / 'current_revision | other_revisions'
  #
  # hierarchy level:
  #   1. fqdn
  #   2. flock
  #   3. environment
  #   4. default
  #
  #   Note: Hierarchy means, a revision at 'fqdn' level overrides the default
  #   and any other level revisions for a node.
  #   If no revision exists for a node at 'fqdn' level, then 'flock' level will
  #   be searched and so on.
  #
  databag = data_bag_item(node['javadeploy']['databag'], "revision_#{level}")
  revisions = databag['repositories'][repository]
  if revisions
    rev = revisions[type]
  else
    rev = nil
  end
  rev
end

def repository
  if new_resource.action == :create
    resource_action = :create
    setup_resource = true
  else
    resource_action = :delete
    setup_resource = false
  end

  # repo name
  repo_name = new_resource.name
  service_name = new_resource.service_name || repo_name

  # repo home
  repo_home = ::File.join(node['javadeploy']['repositories_dir'], repo_name)

  directory repo_home do
    owner new_resource.user
    group new_resource.group
    mode new_resource.dir_mode
    recursive true
    action resource_action
  end

  # repo revisions directory
  repo_revisions_dir = ::File.join(repo_home, 'revisions')

  directory repo_revisions_dir do
    owner new_resource.user
    group new_resource.group
    mode new_resource.dir_mode
    recursive true
    action resource_action
  end

  # revisions
  if new_resource.databag_revision
    repository_other_revisions = other_revisions(repo_name)
    repository_current_revision = current_revision(repo_name)
  else
    repository_other_revisions = new_resource.other_revisions
    repository_current_revision new_resource.current_revision
  end

  default_revision_dir = ::File.join(repo_revisions_dir, 'default')
  current_revision_dir = ::File.join(repo_revisions_dir, repository_current_revision)

  repo_revisions = repository_other_revisions
  repo_revisions.push repository_current_revision

  # purge stale revisions
  ruby_block "purge-revisions-#{repo_name}" do
    block do
      require 'fileutils'
      existing_revisions =  Dir.entries(repo_revisions_dir).reject { |a| a =~ /^\.{1,2}$/ }.sort
      keep_revisions = repo_revisions.sort
      keep_revisions.push 'default'
      delete_revisions = existing_revisions - keep_revisions

      delete_revisions.each do |rev|
        rev_dir = ::File.join(repo_revisions_dir, rev)
        if ::File.directory?(rev_dir)
          FileUtils.rm_rf Dir.glob(rev_dir)
          Chef::Log.warn("deleted revision #{rev_dir}")
        end
      end
    end
    only_if { setup_resource && new_resource.purge }
  end

  # repo git ssh wrapper file
  # need to add resource
  ssh_key_wrapper_file = new_resource.ssh_key_wrapper_file || ::File.join(node['javadeploy']['ssh_key_wrapper_dir'], "#{new_resource.ssh_key_wrapper}_wrapper")

  # setup ssh_key_wrapper_file resource
  # ssh_key_wrapper repo_name do
  #  databag new_resource.ssh_key_wrapper_databag
  #  key_file ::File.join(node['javadeploy']['ssh_key_wrapper_dir'], new_resource.ssh_key_wrapper)
  #  wrapper_file ssh_key_wrapper_file
  #  user new_resource.user
  #  group new_resource.group
  #  not_if { ::File.exist?(new_resource.ssh_key_wrapper_file) }
  #  only_if { setup_resource }
  # end

  # sync repo revisions
  repo_revisions.each do |revision|
    git ::File.join(repo_revisions_dir, revision) do
      repository new_resource.repository_url
      revision revision
      ssh_wrapper ssh_key_wrapper_file
      user new_resource.user
      group new_resource.group
      action new_resource.repository_action
      only_if { setup_resource }
    end
  end

  # verify a file to validate a repository
  fail "verify file does not exists - #{new_resource.verify_file}" if new_resource.verify_file && !::File.join(default_revision_dir, new_resource.verify_file)

  pid_file = ::File.join(repo_home, 'service.pid')
  log_file = new_resource.console_log ? ::File.join(node['javadeploy']['log_dir'], "#{repo_name}.log") : '/dev/null'
  class_path = new_resource.class_path.map { |cp| ::File.join(default_revision_dir, cp) }
  class_path += new_resource.ext_class_path
  if class_path.empty?
    class_path = '-cp ' + repo_home
  else
    class_path = '-cp ' + class_path.join(':')
  end

  # add auto calculated java max heap parameter
  new_resource.options.push node['javadeploy']['auto_java_xmx'] if  resource.auto_java_xmx

  file log_file do
    owner new_resource.user
    group new_resource.group
    mode new_resource.dir_mode
    only_if { setup_resource && new_resource.console_log }
    action resource_action
  end

  template "/etc/init.d/#{repo_name}" do
    cookbook new_resource.cookbook
    source 'service_init.erb'
    owner new_resource.user
    group new_resource.group
    mode new_resource.dir_mode
    variables(:user => new_resource.user,
              :group => new_resource.group,
              :home => default_revision_dir,
              :service_name => service_name,
              :pid_file => pid_file,
              :log_file => log_file,
              :class_path => class_path,
              :class_name => new_resource.class_name,
              :options => new_resource.options.join(' '),
              :jar => new_resource.jar,
              :args => new_resource.args.join(' ')
             )
    notifies :restart, "service[#{service_name}]", :delayed if new_resource.notify_restart
    only_if { new_resource.manage_service && new_resource.init_style == 'init' }
    action resource_action
  end

  new_resource.pre_include_recipe.each do |recipe|
    include_recipe recipe
  end

  link default_revision_dir do
    to current_revision_dir
    notifies :restart, "service[#{service_name}]", :delayed
    only_if { setup_resource && resource_action == :create }
  end

  new_resource.post_include_recipe.each do |recipe|
    include_recipe recipe
  end

  service service_name do
    case node['javadeploy']['init_style']
    when 'upstart'
      provider Chef::Provider::Service::Upstart
    end
    supports new_resource.service_supports
    only_if { setup_resource }
    action new_resource.service_action
  end
end
