
def create_robot(args)
  robot_name = args.first
  module_name = robot_name.split("_").collect { |word| word[0, 1].upcase + word[1, word.length-1] }.join("")
  robot_class_name = "#{module_name}::Robot"
  options = { :name => robot_name }
  args[1, args.length-1].each do |arg|
    key, value = arg.split("=").collect { |part| part.strip }
    options[key.to_sym] = value
  end
  dir = File.join(".", robot_name)
  file = File.join(dir, "robot.rb")
  config = File.join(dir, "config.ru")
  #Create the project dir
  puts "Creating directory #{File.expand_path(dir)}"
  Dir.mkdir(dir)
  puts "Creating robot class #{File.expand_path(file)}"
  #Make the base robot class
  File.open(file, "w") do |f|
    f.puts <<-ROBOT
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
  #Make the rackup config file
  puts "Creating rackup config file #{File.expand_path(config)}"
  options_str = options.collect { |key, val| ":#{key} => \"#{val}\"" }.join(", ")
  File.open(config, "w") do |f|
    f.puts <<-CONFIG
options[:Port] = 3000
require 'robot'
run #{robot_class_name}.new( #{options_str} )
    CONFIG
  end
end