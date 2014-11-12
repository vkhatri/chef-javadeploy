
# Enable Auto Memory -Xmx java option
default['javadeploy']['set_java_xmx'] = true

# Minimum Memory to preserve for system
default['javadeploy']['system_memory'] = 768

# Calculate -Xmx (Multiple of 1024)
if node['memory'] && node['memory'].key?('total')
  total_memory = (node['memory']['total'].gsub('kB', '').to_i / 1024).to_i
  total_memory_percentage = (total_memory % 1024)
  system_memory = if total_memory < 2048
                    total_memory / 2
                  else
                    if total_memory_percentage >= node['javadeploy']['system_memory'].to_i
                      total_memory_percentage
                    else
                      total_memory_percentage + 1024
                    end
                  end

  java_memory = total_memory - system_memory
  # Making Java -Xmx even
  java_memory += 1 unless java_memory.even?
  node.default['javadeploy']['auto_java_xmx'] = "-Xmx#{java_memory}m"
end
