require 'yaml'
require 'fileutils'

print 'Converting AutoDisplayManager configuration from v. 0.1 to v. 1.0... '
homepath = ENV["HOME"]
if File.exists?("#{homepath}/.auto-display-manager/config.yml")
  old_config = YAML.load_file("#{homepath}/.auto-display-manager/config.yml")
  new_config = {}
  new_config[:displays] = old_config[:displays]
  new_config[:displays] ||= []
  new_config[:profiles] = ['default']
  new_config['default'] = {}
  old_config[:displays].each do |d|
    new_config['default'][d] = old_config[d]
  end
  File.open("#{homepath}/.auto-display-manager/config.yml", "w") do |f|
    f << YAML.dump(new_config)
  end
  puts 'Success!'
else
  puts 'Failure!'
  puts 'AutoDisplayManager configuration does not exist! Exiting...'
end