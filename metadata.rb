name 'javadeploy'
maintainer 'Virender Khatri'
maintainer_email 'vir.khatri@gmail.com'
license 'Apache 2.0'
description 'Deploy/Manage Java Git Repositories Projects as a Service with Version Control'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.6'

depends 'ulimit'
depends 'java'
# depends 'ssh_key_wrapper'

%w(ubuntu redhat centos fedora amazon).each do |os|
  supports os
end
