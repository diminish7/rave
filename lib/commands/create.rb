require 'ftools'

#Creates a project for a robot.  Args are:
# => robot_name (required)
# => image_url=http://imageurl.com/icon.png (optional)
# => profile_url=http://profileurl.com/ (optional)
# e.g. rave my_robot image_url=http://appropriate-casey.appspot.com/image.png profile_url=http://appropriate-casey.appspot.com/profile.json
def create_robot(args)
  robot_name = args.first
  module_name = robot_name.split(/_|-/).collect { |word| word.capitalize }.join
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
  run = File.join(dir, "config.ru")
  config = File.join(dir, "config.yaml")
  public_folder = File.join(dir, "public")
  html = File.join(public_folder, "index.html")
  here = File.dirname(__FILE__)
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
appcfg:
  version: 1
CONFIG
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

  <p>This is a Google Wave robot using <a href="http://github.com/diminish7/rave">Rave</a> running in JRuby.
   Use this robot in your Google Waves by adding <em>#{id}</em> as a participant</p>

  <img src="http://code.google.com/appengine/images/appengine-silver-120x30.gif" alt="Powered by Google App Engine" />
</body>
</html>
HTML
end
