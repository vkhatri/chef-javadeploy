javadeploy Cookbook
===================

[![Build Status](https://travis-ci.org/vkhatri/chef-javadeploy.svg?branch=master)](https://travis-ci.org/vkhatri/chef-javadeploy)

This is a [Chef] cookbook to Deploy/Manage `Java` Projects/Repositories.

This cookbook makes deploying a Java Git Repository (with tag/revision control) very
easy and efficient.

It setup any Java project as a Service with Java Options.

More details yet to be updated.

## Repository

http://vkhatri.github.io/chef-javadeploy


## Supported JDK Versions

There is not limitation on Java to use this cookbook.

Java is setup and managed by `java` cookbook.


## Cookbook Dependencies

* `ulimit` cookbook
* `java` cookbook


## Recipes

- `javadeploy::default`     - default cookbook, wrapper for cookbook recipes

- `javadeploy::java`        - recipe to setup java

- `javadeploy::user`        - recipe to setup user for java services

- `javadeploy::core`        - recipe to setup core cookbook resources

## javadeploy LWRP

**LWRP example**

*Create a java project using LWRP:*

    javadeploy 'repository' do
      option value
    end


*Delete a java project using LWRP:*

    javadeploy 'repository' do
      option value
      action :delete
    end


**LWRP Options**

Parameters:

- *repository_url (required)*     - java project git repository
- *action (optional)*         - default :create, options: :create, :delete
- *user (optional)*           - service/directory/file user permission, default value `node[:javadeploy][:user]`
- *group (optional)*          - service/directory/file group permission, default value `node[:javadeploy][:group]`
- ...

## Cookbook Advanced Attributes

* `default[:javadeploy][:install_java]` (default: `true`): setup java, disable to manage java outside of this cookbook

* `default[:javadeploy][:manage_user]` (default: `true`): setup service user

* `default[:javadeploy][:console_log]` (default: `true`): enable console log capture to a log file

* `default[:javadeploy][:notify_restart]` (default: `true`): notify service restart upon a resource create/update

* `default[:javadeploy][:purge]` (default: `true`): purge a repository revisions, if set keeps only provided set of revisions checkout

* `default[:javadeploy][:repositories]` (default: `true`): repositories to setup using lwrp from `databag` source

* `default[:javadeploy][:revision_override][:fqdn]` (default: `true`): repositories revision override for a `fqdn`

* `default[:javadeploy][:revision_override][:flock]` (default: `true`): repositories revision override for a `cluster or flock`

* `default[:javadeploy][:revision_override][:environment]` (default: `true`): repositories revision override for an `environment`

* <del> `default[:javadeploy][:databag]` (default: `javadeploy`): databag source for repositories, not yet supported </del>


## Cookbook Core Attributes

* `default[:javadeploy][:base_dir]` (default: `/opt/javadeploy`): base directory for repositories, logs etc.

* `default[:javadeploy][:user]` (default: `jdeploy`): javadeploy default service user

* `default[:javadeploy][:group]` (default: `jdeploy`): javadeploy service user group

* `default[:javadeploy][:group]` (default: `dir_mode`): javadeploy resources dir/files default mode permissions

* `default[:javadeploy][:log_dir]` (default: `/opt/javadeploy/logs`): javadeploy service log file

* `default[:javadeploy][:repositories_dir]` (default: `/opt/javadeploy/repositories`): home directory for a java repository

* `default[:javadeploy][:manage_service]` (default: `true`): if set, will create a service for a java repository with provided options

* `default[:javadeploy][:java_options]` (default: `[]`): default java options for lwrp

* `default[:javadeploy][:current_revision]` (default: `master`): default git repository revision for lwrp repository resource

## Cookbook Ulimit Attributes

 * `default[:javadeploy][:limits][:memlock]` (default: `unlimited`): service user memory limit

 * `default[:javadeploy][:limits][:nofile]` (default: `48000`): service user file limit

 * `default[:javadeploy][:limits][:nproc]` (default: `unlimited`): service user process limit


## TODO

* add databag source
* add revision override feature
* add ssh key wrapper cookbook for key/wrapper management from a databag


## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests (`rake`), ensuring they all pass
6. Write new resource/attribute description to `README.md`
7. Write description about changes to PR
8. Submit a Pull Request using Github


## Copyright & License

Authors:: Virender Khatri and [Contributors]

<pre>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</pre>

[Chef]: https://www.getchef.com/chef/
[Contributors]: https://github.com/vkhatri/chef-javadeploy/graphs/contributors
