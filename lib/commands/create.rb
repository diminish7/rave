require 'ftools'

#Creates a project for a robot.  Args are:
# => robot_name (required)
# => image_url=http://imageurl.com/icon.png (optional)
# => profile_url=http://profileurl.com/ (optional)
# e.g. rave my_robot image_url=http://appropriate-casey.appspot.com/image.png profile_url=http://appropriate-casey.appspot.com/profile.json
def create_robot(args)
  robot_name = args.first
  module_name = 'MyRaveRobot'
  robot_class_name = "#{module_name}::Robot"
  
  options = { :name => robot_name, :version => 1, :id => "#{robot_name}@appspot.com" }
  args[1, args.length-1].each do |arg|
    key, value = arg.split("=").collect { |part| part.strip }
    options[key.to_sym] = value
  end

  dir = File.join(".", robot_name)
  if File.exist? dir
    puts "Directory #{dir}/ already exists. Exiting..."
    exit
  end
  
  lib = File.join(dir, "lib")
  config_dir = File.join(dir, "config")
  file = File.join(dir, "robot.rb")
  appengine_web = File.join(dir, "appengine-web.xml")
  run = File.join(dir, "config.ru")
  config = File.join(dir, "config.yaml")
  public_folder = File.join(dir, "public")
  html = File.join(public_folder, "index.html")
  here = File.dirname(__FILE__)
  rake = File.join(dir, "Rakefile")
  jar_dir = File.join(here, "..", "jars")
  jars = %w( appengine-api-1.0-sdk-1.2.8.jar jruby-core.jar ruby-stdlib.jar )

  #Create the project dir
  puts "Creating directory #{File.expand_path(dir)}"
  Dir.mkdir(dir)

  puts "Creating robot class #{File.expand_path(file)}"
  #Make the base robot class
  File.open(file, "w") do |f|
    f.puts robot_file_contents(module_name)
  end

  # Make the rackup run file.
  puts "Creating rackup config file #{File.expand_path(run)}"
  File.open(run, "w") do |f|
    f.puts run_file_contents(robot_class_name, file)
  end

  # Make up the yaml config file.
  puts "Creating configuration file #{File.expand_path(config)}"
  File.open(config, "w") do |f|
    f.puts config_file_contents(options)
  end

  # Make up the html index file.
  puts "Creating Rakefile #{File.expand_path(rake)}"
  File.open(rake, "w") do |f|
    f.puts rake_file_contents(config)
  end

  #Make the appengine web xml file
  puts "Creating appengine config file #{File.expand_path(appengine_web)}"
  File.open(appengine_web, "w") do |f|
    f.puts appengine_web_contents(robot_name)
  end

  #Make the public folder for static resources
  puts "Creating public folder"
  Dir.mkdir(public_folder)

  # Make up the html index file.
  puts "Creating html index file #{File.expand_path(html)}"
  File.open(html, "w") do |f|
    f.puts html_file_contents(robot_name, options[:id])
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
    #Define handlers here:
    # e.g. if the robot should act on a DOCUMENT_CHANGED event:
    # 
    # def document_changed(event, context)
    #   #Do some stuff
    # end
    # 
    # Events are: 
    # 
    # WAVELET_BLIP_CREATED, WAVELET_BLIP_REMOVED, WAVELET_PARTICIPANTS_CHANGED,
    # WAVELET_TIMESTAMP_CHANGED, WAVELET_TITLE_CHANGED, WAVELET_VERSION_CHANGED,
    # BLIP_CONTRIBUTORS_CHANGED, BLIP_DELETED, BLIP_SUBMITTED, BLIP_TIMESTAMP_CHANGED,
    # BLIP_VERSION_CHANGED, DOCUMENT_CHANGED, FORM_BUTTON_CLICKED
    #
    # If you want to name your event handler something other than the default name, 
    # or you need to have more than one handler for an event, you can register handlers
    # in the robot's constructor:
    #
    # def initialize(options={})
    #   super
    #   register_handler(Rave::Models::Event::DOCUMENT_CHANGED, :custom_doc_changed_handler)
    # end
    # 
    # def custom_doc_changed_handler(event, context)
    #   #Do some stuff
    # end
    # 
    # Note: Don't forget to call super if you define #initialize
    
  end
end
ROBOT
end

def run_file_contents(robot_class_name, robot_file)
  <<-CONFIG
require '#{File.basename(robot_file).chomp(File.extname(robot_file))}'
run #{robot_class_name}.instance
CONFIG
end

def config_file_contents(options)
  <<-CONFIG
robot:
  id: #{options[:id]}
  name: #{options[:name]}
  image_url: #{options[:image_url]}
  profile_url: #{options[:profile_url]}
  version: #{options[:version]}
  file: #{options[:file] or 'robot.rb'}

appcfg: C:/appengine-java-sdk/bin/appcfg
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
require 'yaml'
config_file = 'config.yaml'
config = YAML::load(File.open(config_file))
robot_file = config['robot']['file']
Warbler::Config.new do |config|
  config.gems = %w( rave json-jruby rack builder )
  config.includes = %w( appengine-web.xml ) + [config_file, robot_file]
end
WARBLE
end

def html_file_contents(name, id)
  <<-HTML
<html>
<head>
  <title>#{name}</title>
</head>
<body>
  <h1>#{name}</h1>

  <img src="icon.png" alt="#{name} icon" />

  <p>This is a Google Wave robot using <a href="http://github.com/diminish7/rave">Rave</a>
   running in jruby with the Google Wave Java API.
   Use this robot in your Google Waves by adding <em>#{id}</em> as a participant</p>

  <img src="http://code.google.com/appengine/images/appengine-silver-120x30.gif" alt="Powered by Google App Engine" />
</body>
</html>
HTML
end

def rake_file_contents(config_file)
  <<-RAKE
# Rakefile
require 'spec/rake/spectask'
require 'rake/clean'
require 'yaml'

config_file = '#{File.basename(config_file)}'

CLOBBER.include FileList['*.war']
CLEAN.include FileList['tmp']

desc "Build war archive"
task :build do
  cmd = "rave war"
  cmd = "jruby -S \#{cmd}" if RUBY_PLATFORM == 'java'
  system cmd
end

desc "Deploy as robot (requires appspot account)"
task :deploy => :build do
  config = YAML::load(File.open(config_file))
  system "\#{config['appcfg']} update #{File.join('tmp', 'war')}"
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

task :test => :spec
RAKE
end
