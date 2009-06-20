require 'ftools'

#Creates a project for a robot.  Args are:
# => robot_name (required)
# => image_url=http://imageurl.com/ (optional)
# => profile_url=http://profileurl.com/ (optional)
# e.g. rave my_robot image_url=http://appropriate-casey.appspot.com/image.png profile_url=http://appropriate-casey.appspot.com/profile.json
def create_robot(args)
  robot_name = args.first
  module_name = robot_name.split(/_|-/).collect { |word| word[0, 1].upcase + word[1, word.length-1] }.join("")
  robot_class_name = "#{module_name}::Robot"
  options = { :name => robot_name }
  args[1, args.length-1].each do |arg|
    key, value = arg.split("=").collect { |part| part.strip }
    options[key.to_sym] = value
  end
  dir = File.join(".", robot_name)
  lib = File.join(dir, "lib")
  config_dir = File.join(dir, "config")
  file = File.join(dir, "robot.rb")
  appengine_web = File.join(dir, "appengine-web.xml")
  config = File.join(dir, "config.ru")
  here = File.dirname(__FILE__)
  jar_dir = File.join(here, "..", "jars")
  jars = %w( appengine-api-1.0-sdk-1.2.1.jar jruby-core.jar ruby-stdlib.jar )
  #Create the project dir
  puts "Creating directory #{File.expand_path(dir)}"
  Dir.mkdir(dir)
  puts "Creating robot class #{File.expand_path(file)}"
  #Make the base robot class
  File.open(file, "w") do |f|
    f.puts robot_file_contents(module_name)
  end
  #Make the rackup config file
  puts "Creating rackup config file #{File.expand_path(config)}"
  options_str = options.collect { |key, val| ":#{key} => \"#{val}\"" }.join(", ")
  File.open(config, "w") do |f|
    f.puts config_file_contents(robot_class_name, options_str)
  end
  #Make the appengine web xml file
  puts "Creating appengine config file #{File.expand_path(appengine_web)}"
  File.open(appengine_web, "w") do |f|
    f.puts appengine_web_contents(robot_name)
  end
  #Copy jars over
  puts "Creating lib directory #{File.expand_path(lib)}"
  Dir.mkdir(lib)
  jars.each do |jar|
    puts "Adding jar #{jar}"
    File.copy(File.join(jar_dir, jar), File.join(lib, jar))
  end
  #Make the wabler config file
  puts "Creating config directory #{File.expand_path(config_dir)}"
  Dir.mkdir(config_dir)
  warble_file = File.join(config_dir, "warble.rb")
  puts "Creating warble config file #{File.expand_path(warble_file)}"
  File.open(warble_file, "w") do |f|
    f.puts warble_config_contents()
  end
end

def robot_file_contents(module_name)
  <<-ROBOT
require 'rubygems'
require 'rave'

module #{module_name}
  class Robot < Rave::Models::Robot
    
    def initialize(options={})
      super(options)
      #TODO: register handlers here.
      # e.g. If a DOCUMENT_CHANGED event should trigger a method called doc_changed(event, context):
      #      register_handler(Rave::Models::Event::DOCUMENT_CHANGED, :doc_changed)
    end
    
  end
end
ROBOT
end

def config_file_contents(robot_class_name, options_str)
  <<-CONFIG
require 'robot'
run #{robot_class_name}.new( #{options_str} )
CONFIG
end

def appengine_web_contents(robot_name)
  <<-APPENGINE
<?xml version="1.0" encoding="utf-8"?>
<appengine-web-app xmlns="http://appengine.google.com/ns/1.0">
    <application>#{robot_name}</application>
    <version>1</version>
    <static-files />
    <resource-files />
    <sessions-enabled>false</sessions-enabled>
    <system-properties>
      <property name="jruby.management.enabled" value="false" />
      <property name="os.arch" value="" />
      <property name="jruby.compile.mode" value="JIT"/> <!-- JIT|FORCE|OFF -->
      <property name="jruby.compile.fastest" value="true"/>
      <property name="jruby.compile.frameless" value="true"/>
      <property name="jruby.compile.positionless" value="true"/>
      <property name="jruby.compile.threadless" value="false"/>
      <property name="jruby.compile.fastops" value="false"/>
      <property name="jruby.compile.fastcase" value="false"/>
      <property name="jruby.compile.chainsize" value="500"/>
      <property name="jruby.compile.lazyHandles" value="false"/>
      <property name="jruby.compile.peephole" value="true"/>
   </system-properties>
</appengine-web-app>
APPENGINE
end

def warble_config_contents
  <<-WARBLE
Warbler::Config.new do |config|
  config.gems = %w( rave )
  config.includes = %w( robot.rb appengine-web.xml )
end
WARBLE
end