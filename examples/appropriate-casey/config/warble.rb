Warbler::Config.new do |config|
  config.gems = %w( rave json-jruby rack builder RedCloth )
  config.includes = %w( robot.rb config.yaml appengine-web.xml )
end
