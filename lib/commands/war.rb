require 'rubygems'
require 'rake'
require File.join(File.dirname(__FILE__), 'task.rb')

#Runs warbler to package up the robot
# then does some cleanup that is specific to App Engine:
# => Deletes the complete JRuby jar from both the app's lib folder and
#    the frozen warbler gem, and replaces them with a broken up version
# => Changes the file path json-jruby 
#    TODO: Not sure why this is necessary, but it doesn't run on appengine without it
def create_war(args)
  Rake.application.standard_exception_handling do
    Rake.application.init
    Rave::Task.new
    task(:default => "rave:create_war")
    Rake.application.top_level
  end
end