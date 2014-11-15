javadeploy Cookbook
===================

[![Build Status](https://travis-ci.org/vkhatri/chef-javadeploy.svg?branch=master)](https://travis-ci.org/vkhatri/chef-javadeploy)

This is a [Chef] cookbook to Deploy/Manage `Java` Projects Git Repositories.

This cookbook deploys a multi revisions service for multiple Java Git Repository with ease of revision control hierarchy management.



## Repository

http://vkhatri.github.io/chef-javadeploy/


## Supported JDK Versions

There is no limitation on Java to use this cookbook.

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

*Create a java service using LWRP:*


    javadeploy 'GIT_REPOSITORY' do
	  ssh_key_wrapper_file '/opt/javadeploy/ssh_key_wrapper/GIT_REPOSITORY_KEY.wrapper'
	  repository_url 'git@github.com:GITHUB_USER/GIT_REPOSITORY.git'
	  options ["-Dcom.sun.management.jmxremote.ssl=false",
    	"-Dlog4j.configuration=log4j.xml",
    	"-Dlog4j.debug=info",
    	"-Dfile.encoding=UTF-8",
    	"-Xdebug"
	  ]
	  class_name 'java.className'
	  class_path ["config/#{node.environment}",
		'package/lib/*',
		'package/resources',
		'package/*'
	  ]
	  console_log false
	  current_revision 'CURRENT_REVISION'
	  other_revisions ['OLD_REVISION_1', 'OLD_REVISION_2']
	end


*Delete a java project using LWRP:*

    javadeploy 'GIT_REPOSITORY' do
      option value
      action :delete
    end


**LWRP Options**

Parameters:

- *name (required)* - repository name, default lwrp parameter
- *action (optional)* - repository lwrp action, options: :create :delete, default `:create`

- *repository_url (required)*  - java project git repository url
- *repository_checkout (required)*  - java project git repository checkout action, default `node['javadeploy']['repository_checkout']`

- *user (optional)* - service/directory/file user, default `node['javadeploy']['user']`
- *group (optional)* - service/directory/file group, default `node['javadeploy']['group']`
- *dir_mode (optional)* - file/directory resource permissions, default `node['javadeploy']['dir_mode']`

- *service_name (optional)* - repository service name, default `:name`
- *manage_service (optional)* - create service for repository, default `node['javadeploy']['manage_service']`
- *service_action (optional)* - service resource action, default `node['javadeploy']['service_action']`
- *service_supports (optional)* - service resource supports attribute, default `node['javadeploy']['service_supports']`
- *init_style (optional)* - managed service init style, default `node['javadeploy']['init_style']`

- *ssh_key_wrapper_file (optional)* - git repository ssh wrapper file, default `nil`
- *console_log (optional)* - whether to redirect console log to `#{:name}.log` file under `node['javadeploy']['log_dir']`, default `node['javadeploy']['console_log']`
- *verify_file (optional)* - file location to validate under repository revision, e.g. `directory/file`, default `node['javadeploy']['verify_file']`

- *class_path (optional)* - java class path under repository revision directory, default `node['javadeploy']['class_path']`
- *ext_class_path (optional)* - java class path outside repository revision directory, default `node['javadeploy']['ext_class_path']`
- *class_name (required)* - java class path under repository revision directory, default `node['javadeploy']['class_path']`
- *options (optional)* - java options, default `node['javadeploy']['java_options']`
- *jar (optional)* - java jar file, default `node['javadeploy']['jar']`
- *args (optional)* - java arguments, default `node['javadeploy']['args']`
- *auto_java_xmx (optional)* - add java option `-Xmx` automatically to java options, default `node['javadeploy']['set_java_xmx']`

- *environment (optional)* - node environment to determine repository revisions value from databag, default `node.environment`
- *flock (optional)* - node flock/cluster name to determine repository revisions value from databag, default `node[node['javadeploy']['flock_attribute']]`
- *current_revision (optional)* - repository current revision, default `node['javadeploy']['current_revision']`
- *other_revisions (optional)* -  repository other revisions to keep, default `[]`
- *databag_revision (optional)* - whether to determine revision from a databag hierarchy, default `node['javadeploy']['databag_revision']`
- *file_revision (optional)* - if a file name is specified & file exists, determine revision from specified file, file must be a json file, default `node['javadeploy']['file_revision']`

- *notify_restart (optional)* - whether to notify service on resource udpate, default `node['javadeploy']['notify_restart']`
- *revision_service_notify_action (optional)* - service notify action on revision change, default `node['javadeploy']['revision_service_notify_action']`
- *revision_service_notify_timing (optional)* - service notify timing on revision change, default `node['javadeploy']['revision_service_notify_timing']`

- *cookbook (optional)* - templates cookbook, default `javadeploy`
- *purge (optional)* - purge repository revisions and keep only current_revision and other_revisions, default `node['javadeploy']['purge']`


## Cookbook Repository Revision Types

For a repository, revision is categorized into two types:

* `current` - current revision or default revision on which java service will be running, it can be configured using LWRP attribute `current_revision` or defining attribute `current_revision` in local json file on node / databag hierarchy

* `other` - other revision(s) or list of revisions which are meant to preserve on a node for roll back or other purposes, it can be configured using LWRP attribute `other_revisions` or defining attribute `other_revisions` in local json file on node / databag hierarchy


## Cookbook LWRP Revision Attributes & Precedence

Repository revisions can be managed in different ways using this cookbook.

#### LWRP Resource attributes precedence

* `:file_revision` - from a local json file
* `:databag_revision` - from databag hierarchy of `node fqdn, node cluster, node environment or default revision`
* `:current_revision & :other_revisions` - using lwrp resource attributes `current_revision` & `other_revisions`

Idea is to minimize the effort to change and manage
revision for multiple repositories in a simplest way possible.


#### LWRP Resource attributes

**:file_revision**

To configure repository `current` & `other` revisions value from a local file, set lwrp
resource attribute `:file_revision`.

Default value for `:file_revision` resource attribute is `node['javadeploy']['file_revision']`.

If this file exist and contain revision attributes `current_revision` & `other_revisions` for the repository, `current` & `other` revisions value will be set from the `:file_revision` file.

Note: `:file_revision` gets `first` precedence to determine `current` & `other` revisions value and overrides `:databag_revision` and lwrp resource attributes `current_revision` & `other_revision`.

**:databag_revision**

To determine repository `current` & `other` revisions value from databag, set attribute `:databag_revision` to true.

Default value for `:databag_revision` resource attribute is `node['javadeploy']['databag_revision']`.

There are two scenarios if `:databag_revision` resource attribute is set:

1. If `:file_revision` resource attribute is defined and revision attribute value were found in `:file_revision` file, LWRP will `NOT` look up into databag items hierarchy.

2. If `:file_revision` resource attribute is defined and revision attributes were `NOT` found in `:file_revision` file, LWRP will look up into databag items hierarchy.

3. If `:file_revision` resoruce attribute is `NOT` defined, LWRP will simply lookup databag hierarchy to determine revision attributes.


Note: `:databag_revision` gets `second` precedence to determine revisions value & overrides lwrp resource attributes `current_revision` & `other_revision`

**:current_revision & :other_revisions**

This is the simplest way to configure repository revisions.

LWRP will use resource attributes - `:current_revision` as `current` revision & `:other_revisions` as `other` revisions only in below scenarios:

1. if resource attributes `:file_revision` & `databag_revision` are not set
2. or resource attributes `:file_revision` & `databag_revision` are set but were unable to determine `current`/`others` revisions value

Note: `current_revision` & `other_revision` gets least precedence to determine revisions value.

Default value for resource attribute `current_revision` is set to `node['javadeploy']['current_revision']`.

Default value for resource attribute `other_revisions` is set to `[]`.


## Cookbook LWRP Revision using Resource Attributes

As mentioned earlier there are two types of revisions `current` and `other`.

Both can be configured with in LWRP using resource attributes - `current_revision` & `other_revisions`.

Resource attribute `other_revisions` is an Array resource to keep more than one older revisions, useful for roll back.

Managing repository revision with in LWRP resource is a best way if revision always refers to a branch.

## Cookbook LWRP Revision from a JSON File

For each repository, `current` or `other` revisions value can be configured by a local JSON file.

Local JSON file location is common for all repositories and configurable by attribute `node['javadeploy']['file_revision']`.

**Local JSON Revision File Format**


	{
	  "repositories": {
	    "repository1": {
		  "current_revision": "rev03",
		  "other_revisions": ["rev01", "rev02"]
		},
	    "repository2": {
		  "current_revision": "rev02",
		  "other_revisions": ["rev01", "rev03"]
		},
	    "repository3": {
		  "current_revision": "rev03"
		},
	    "backend": {
		  "other_revisions": ["rev01","rev02"]
		}
	  }
	}


>> If attribute `node['javadeploy']['file_revision']` is not configured, LWRP will not lookup local file for revisions value.

>> If a repository or repository revisions are not present in the file, LWRP will try to look up revisions in next configured precedence.

Managing repoisitory revisions from a local json file could be a problem especially running in cloud infrastructure where node replacement or rebuils requires its preservation.

But, it is a quick solution to verify the revision without making any change in cookbook or data bag.

## Cookbook LWRP Revision from Data Bag Hierarchy



Managing repository revisions using data bag is a better way if revisions are keep changing very frequently and revisions vary among nodes, clusters and environments.

**Enable Data Bag Revisions for One or All Repositories**

To configure a repository revisions using databag, simply set lwrp resource attribute `:databag_revision`, default value is configured by attribute `node['javadeploy']['databag_revision']`.

By setting attribute `node['javadeploy']['databag_revision']` to `true`, all repositories or LWRP resources will look up data bag for revisions depending upon the precedence.

**Data Bag Name**

Cookbook data bag name is configurable by attribute `node['javadeploy']['databag']`.


**Data Bag Items**

There are total four data bag items used by LWRP to maintain repository revisions hierarchy:

* revision_fqdn
* revision_flock
* revision_environment
* revision_default

>> 		Hierarchy does not mean that LWRP performs any kind of attributes merge 
	 on different data bag items.
		It means if a value is found in a data bag item for repository 
	 `current_revision` or `other_revisions`, next data bag items will 
	 not be checked and will simply ignored.

>>		e.g. a repository revision is configured in data bag item `revision_fqdn` 
	 which means all other data bag items will be ignored.
		If no revision is found in `revision_fqdn` data bag item, LWRP will check 
		`revision_flock` and so on in the hierarchy.



**Data Bag Items Sample**

***revision_fqdn***

	{
	  "id": "revision_fqdn",
	  "description": "Node FQDN Revision",
	  "repositories": {
	    "fqdn1": {
		  "repository1": {
		  	"current_revision": ,
		  	"other_revisions": null
		  },
		  "repository2": {
		  	"current_revision": null,
		  	"other_revisions": null
		  }
		},
	    "fqdn2": {
		  "repository1": {
		  	"current_revision": ,
		  	"other_revisions": null
		  },
		  "repository2": {
		  	"current_revision": null,
		  	"other_revisions": null
		  }
		}
	  }
	}


***revision_flock***

	{
	  "id": "revision_fqdn",
	  "description": "Node Cluster Revision",
	  "repositories": {
	    "cluster1": {
		  "repository1": {
		  	"current_revision": "rev",
		  	"other_revisions": null
		  },
		  "repository2": {
		  	"current_revision": "rev",
		  	"other_revisions": null
		  }
		},
	    "cluster2": {
		  "repository1": {
		  	"current_revision": "rev",
		  	"other_revisions": null
		  },
		  "repository2": {
		  	"current_revision": null,
		  	"other_revisions": null
		  }
		}
	  }
	}

***revision_environment***

	{
	  "id": "revision_environment",
	  "description": "Environment Revision",
	  "repositories": {
	    "environment1": {
		  "repository1": {
		  	"current_revision": "rev",
		  	"other_revisions": ["rev", "rev2"]
		  },
		  "repository2": {
		  	"current_revision": null,
		  	"other_revisions": null
		  }
		},
	    "environment2": {
		  "repository1": {
		  	"current_revision": "rev1",
		  	"other_revisions": null
		  },
		  "repository2": {
		  	"current_revision": null,
		  	"other_revisions": ["rev"]
		  }
		}
	  }
	}

***revision_default***

	{
	  "id": "revision_fqdn",
	  "description": "FQDN Revision",
	  "repositories": {
	    "default": {
		  "repository1": {
		  	"current_revision": "rev",
		  	"other_revisions": null
		  },
		  "repository2": {
		  	"current_revision": null,
		  	"other_revisions": ["rev"]
		  }
		}
	  }
	}

## Cookbook Revision Precedence Scenarios

Information not yet added.


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

* `default[:javadeploy][:init_style]` (default: `init`): init style for javadeploy repository service

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
* add/test debian init script
* add more init style

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
