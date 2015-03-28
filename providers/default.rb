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
  # may be deep merge is a better approach
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
  databag = data_bag_item(node['javadeploy']['databag'], "revision_#{level}")
  fail "incorrect attributes, missing root element 'repositories' in databag item 'revision_#{level}'" unless databag.key?('repositories')
  revision_value = nil
  case level
  when 'fqdn'
    revision_value = databag['repositories'][node['fqdn']][repository] if databag['repositories'].key?(node['fqdn']) && node['fqdn']
  when 'flock'
    revision_value = databag['repositories'][new_resource.flock][repository] if new_resource.flock && databag['repositories'].key?(new_resource.flock)
  when 'environment'
    revision_value = databag['repositories'][new_resource.environment][repository] if new_resource.environment && databag['repositories'].key?(new_resource.environment)
  when 'default'
    fail "incorrect attribute, missing sub element 'default' in databag item 'revision_#{level}'" unless databag['repositories'].key?('default')
    revision_value = databag['repositories']['default'][repository]
  end
  revision_value = revision_value[type] if revision_value
  revision_value
end

def repository
  if (new_resource.action.is_a?(Array) && new_resource.action.include?(:delete)) || (new_resource.action.is_a?(Symbol) && new_resource.action == :delete)
    resource_action = :delete
    setup_resource = false
  else
    resource_action = :create
    setup_resource = true
  end

  # repo name
  repo_name = new_resource.name
  service_name = new_resource.service_name || repo_name

  # repo home
  repo_home = ::File.join(node['javadeploy']['repositories_dir'], repo_name)

  service service_name do
    not_if { setup_resource }
    action :stop
  end

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

  repository_other_revisions = nil
  repository_current_revision = nil
  repo_revisions = []

  # file revisions
  if new_resource.file_revision && ::File.exist?(new_resource.file_revision)
    file_revision = JSON.parse(::File.open(new_resource.file_revision).read)
    fail "incorrect attributes, missing root element 'repositories' in revision file '#{new_resource.file_revision}'" unless file_revision.key?('repositories')
    if file_revision['repositories'].key?(repo_name)
      repository_other_revisions = file_revision['repositories'][repo_name]['other_revisions']
      repository_current_revision = file_revision['repositories'][repo_name]['current_revision']
    end
  end

  # data bag revisions, unless found in file revisions
  if new_resource.databag_revision
    # data bag revisions
    repository_other_revisions = other_revisions(repo_name) unless repository_other_revisions
    repository_current_revision = current_revision(repo_name) unless repository_current_revision
  end

  # unless file_revision or databag_revision is not set or unable to
  # determine values, defaults to resource revisions
  repository_other_revisions = new_resource.other_revisions unless repository_other_revisions
  repository_current_revision = new_resource.current_revision unless repository_current_revision

  # set other revisions to an empty array,
  # better to set an empty array to
  # verify class type
  repository_other_revisions = [] unless  repository_other_revisions

  fail "unable to determine 'current_revision' for repository '#{repo_name}'" unless repository_current_revision
  fail "'current_revision' must be a String for repository '#{repo_name}'" unless repository_current_revision.is_a?(String)
  fail "'other_revisions' must be an Array for repository '#{repo_name}'" unless repository_other_revisions.is_a?(Array)

  default_revision_dir = ::File.join(repo_revisions_dir, 'default')
  current_revision_dir = ::File.join(repo_revisions_dir, repository_current_revision)

  Chef::Log.info("sync current_revision '#{repository_current_revision}' for repository '#{repo_name}'")
  Chef::Log.info("sync other_revisions '#{repository_other_revisions.join(', ')}' for repository '#{repo_name}'")

  repo_revisions = repository_other_revisions
  repo_revisions.push repository_current_revision

  # repo git ssh wrapper file
  # need to add resource
  ssh_key_wrapper_file = new_resource.ssh_key_wrapper_file # || ::File.join(node['javadeploy']['ssh_key_wrapper_dir'], "#{new_resource.ssh_key_wrapper}_wrapper")

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

  fail "missing ssh wrapper file '#{ssh_key_wrapper_file}'" unless ::File.readable?(ssh_key_wrapper_file) if setup_resource
  fail 'missing resource attribute :repository_url' if !new_resource.repository_url && setup_resource

  # sync repo revisions
  repo_revisions.sort.uniq.each do |revision|
    git ::File.join(repo_revisions_dir, revision) do
      repository new_resource.repository_url
      revision revision
      depth new_resource.repository_depth if new_resource.repository_depth
      ssh_wrapper ssh_key_wrapper_file
      user new_resource.user
      group new_resource.group
      action new_resource.repository_checkout
      only_if { setup_resource }
    end
  end

  # verify a file to validate a repository
  fail "verify file does not exists - #{new_resource.verify_file}" if new_resource.verify_file && !::File.join(default_revision_dir, new_resource.verify_file)

  pid_file = ::File.join(node['javadeploy']['pid_dir'], "#{repo_name}.pid")
  log_file = new_resource.console_log ? ::File.join(node['javadeploy']['log_dir'], "#{repo_name}.log") : '/dev/null'
  class_path = new_resource.class_path.map { |cp| ::File.join(default_revision_dir, cp) }
  class_path += new_resource.ext_class_path
  if class_path.empty?
    class_path = '-cp ' + repo_home
  else
    class_path = '-cp ' + class_path.join(':')
  end

  # add auto calculated java max heap parameter
  new_resource.options.push node['javadeploy']['auto_java_xmx'] if  new_resource.auto_java_xmx && setup_resource

  file log_file do
    owner new_resource.user
    group new_resource.group
    mode new_resource.dir_mode
    only_if { setup_resource && new_resource.console_log }
    action resource_action
  end

  fail "missing :class_name for repository '#{repo_name}'" unless new_resource.class_name if setup_resource

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
    notifies :restart, "service[#{service_name}]", :delayed if new_resource.notify_restart && setup_resource
    only_if { new_resource.manage_service && new_resource.init_style == 'init' }
    action resource_action
  end

  Chef::Log.info("setting default revision to #{repository_current_revision} for #{repo_name}")

  link default_revision_dir do
    to current_revision_dir
    owner new_resource.user
    group new_resource.group
    notifies new_resource.revision_service_notify_action, "service[#{service_name}]", new_resource.revision_service_notify_timing if new_resource.notify_restart && setup_resource
    only_if { !::File.exist?(default_revision_dir) || (setup_resource && new_resource.migrate && resource_action == :create) }
    action resource_action
  end

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

  service service_name do
    case new_resource.init_style
    when 'upstart'
      provider Chef::Provider::Service::Upstart
    end
    supports new_resource.service_supports
    only_if { setup_resource }
    action new_resource.service_action
  end
end
