Warbler::Config.new do |config|
  config.gems = %w( rave json-jruby rack builder )
  config.includes = %w( robot.rb config.yaml appengine-web.xml )
end
