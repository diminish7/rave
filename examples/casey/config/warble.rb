Warbler::Config.new do |config|
  config.gems = %w( rave json-jruby rack builder )
  config.includes = %w( robot.rb appengine-web.xml )
end
