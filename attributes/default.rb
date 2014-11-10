
default['javadeploy']['install_java'] = true

# repositories collection definition data bag
default['javadeploy']['databag'] = 'javadeploy'

# base directory
default['javadeploy']['base_dir'] = '/opt/javadeploy'

# service user
default['javadeploy']['manage_user'] = true
# keeping user/group length <~8 in favor of ps
default['javadeploy']['user'] = 'jdeploy'
default['javadeploy']['group'] = 'jdeploy'

# default directory/file permissions
default['javadeploy']['dir_mode'] = '0755'

# capture process logs, default goes to /dev/null
default['javadeploy']['console_log'] = true

# notify repo service on resource/revision/etc. change
default['javadeploy']['notify_restart'] = true

default['javadeploy']['revision_override']['fqdn'] = {}
default['javadeploy']['revision_override']['flock'] = {}
default['javadeploy']['revision_override']['environment'] = {}

default['javadeploy']['repositories'] = {}

# Other Attributes
default['javadeploy']['log_dir'] = ::File.join(node['javadeploy']['base_dir'], 'logs')
default['javadeploy']['repositories_dir'] = ::File.join(node['javadeploy']['base_dir'], 'repositories')

# enable purge for old revisions
default['javadeploy']['purge'] = true

# ssh key wrapper data bag
default['javadeploy']['ssh_key_wrapper_dir'] = ::File.join(node['javadeploy']['base_dir'], 'ssh_key_wrapper')
default['javadeploy']['ssh_key_wrapper'] = 'javadeploy'
default['javadeploy']['ssh_key_wrapper_secret'] = nil
default['javadeploy']['ssh_key_wrapper_databag'] = 'javadeploy'

default['javadeploy']['checkout_action'] = :sync
default['javadeploy']['manage_service'] = true
default['javadeploy']['java_options'] = []
default['javadeploy']['current_revision'] = 'master'

default['javadeploy']['env_path'] = nil
default['javadeploy']['init_style'] = 'init'

default['javadeploy']['setup_ulimit'] = true

default['javadeploy']['limits']['memlock'] = 'unlimited'
default['javadeploy']['limits']['nofile'] = '48000'
default['javadeploy']['limits']['nproc'] = 'unlimited'
