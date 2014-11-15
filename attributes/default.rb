
default['javadeploy']['install_java'] = true

# repositories collection definition data bag
default['javadeploy']['databag'] = 'javadeploy'

# set repository revision from a data bag
default['javadeploy']['databag_revision'] = true

default['javadeploy']['flock_attribute'] = 'flock'

# base directory
default['javadeploy']['base_dir'] = '/opt/javadeploy'

# repository service pid dir
default['javadeploy']['pid_dir'] = ::File.join(node['javadeploy']['base_dir'], 'run')

# set repository revision from a file
default['javadeploy']['file_revision'] = ::File.join(node['javadeploy']['base_dir'], 'revisions.json')

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

# service notify action on current revision change
default['javadeploy']['revision_service_notify_action'] = :restart

# delayed service notify on current revision change
default['javadeploy']['revision_service_notify_timing'] = :delayed

# setup java repositories from node attribute
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

default['javadeploy']['repository_checkout'] = :sync
default['javadeploy']['manage_service'] = true

# revision verify file
default['javadeploy']['verify_file'] = nil

default['javadeploy']['class_path'] = []
default['javadeploy']['ext_class_path'] = []
default['javadeploy']['class_name'] = nil
default['javadeploy']['jar'] = nil
default['javadeploy']['args'] = []

default['javadeploy']['java_options'] = []
default['javadeploy']['current_revision'] = 'master'

default['javadeploy']['env_path'] = nil
default['javadeploy']['init_style'] = 'init'

default['javadeploy']['service_action'] = %w(start enable)
default['javadeploy']['service_supports'] = [:status => true, :start => true, :stop => true, :restart => true]

default['javadeploy']['setup_ulimit'] = true

default['javadeploy']['limits']['memlock'] = 'unlimited'
default['javadeploy']['limits']['nofile'] = '48000'
default['javadeploy']['limits']['nproc'] = 'unlimited'
