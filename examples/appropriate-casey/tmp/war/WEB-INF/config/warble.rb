Warbler::Config.new do |config|
  config.gems = %w( rave json-jruby rack builder )
  config.includes = %w( robot.rb appengine-web.xml )
  config.gem_dependencies = true
  config.webxml.booter = :rack
  config.webxml.jruby.init.serial = true
end
