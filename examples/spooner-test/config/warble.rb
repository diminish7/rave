require 'yaml'
config_file = 'config.yaml'
config = YAML::load(File.open(config_file))
robot_file = config['robot']['file']
Warbler::Config.new do |config|
  config.gems = %w( rave json-jruby rack builder )
  config.includes = %w( appengine-web.xml ) + [config_file, robot_file]
end