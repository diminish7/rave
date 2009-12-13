require 'rubygems'
require 'warbler'
require 'rake'

#Runs warbler to package up the robot
# then does some cleanup that is specific to App Engine:
# => Deletes the complete JRuby jar from both the app's lib folder and
#    the frozen warbler gem, and replaces them with a broken up version
# => Changes the file path json-jruby 
#    TODO: Not sure why this is necessary, but it doesn't run on appengine without it
def create_war(args)
  #Set up the config
  warbler_config = Warbler::Config.new do |config|
    config.gems = %w( rave json-jruby rack builder RedCloth )
    config.includes = %w( robot.rb config.yaml )
  end
  #Run warbler
  Rake.application.standard_exception_handling do
    Rake.application.init
    # Load the main warbler tasks
    Warbler::Task.new(:war, warbler_config)
    task(:default => :war)
    Rake.application.top_level
  end
  #Get config info
  config = YAML::load(File.open(File.join(".", "config.yaml")))
  web_inf = File.join(".", "tmp", "war", "WEB-INF")
  rave_jars = File.join(File.dirname(__FILE__), "..", "jars")
  #Delete the complete JRuby jar that warbler sticks in lib
  delete_jruby_from_lib(File.join(web_inf, "lib"))
  #Delete the complete JRuby jar from warbler itself 
  delete_jruby_from_warbler(File.join(web_inf, "gems", "gems"))
  #Copy the broken up JRuby jar into warbler #TODO Is warbler necessary? Can we just delete warbler?
  copy_jruby_chunks_to_warbler(rave_jars, Dir[File.join(web_inf, "gems", "gems", "warbler-*", "lib")].first)
  #Fix the broken paths in json-jruby
  fix_json_jruby_paths(File.join(web_inf, "gems", "gems"))
  #Add the appengine-web.xml file
  robot_name = config['robot']['id'].gsub(/@.+/, '')
  version = config['appcfg'] && config['appcfg']['version'] ? config['appcfg']['version'] : 1
  create_appengine_web(File.join(web_inf, "appengine-web.xml"), robot_name, version)
end

def delete_jruby_from_lib(web_inf_lib)
  jar = Dir[File.join(web_inf_lib, "jruby-complete-*.jar")].first
  puts "Deleting #{jar}"
  File.delete(jar) if jar
end

def delete_jruby_from_warbler(web_inf_gems)
  jar = Dir[File.join(web_inf_gems, "warbler-*", "lib", "jruby-complete-*.jar")].first
  puts "Deleting #{jar}"
  File.delete(jar) if jar
end

def copy_jruby_chunks_to_warbler(rave_jar_dir, warbler_jar_dir)
  puts "Copying jruby chunks"
  %w( jruby-core.jar ruby-stdlib.jar ).each do |jar|
    File.copy(File.join(rave_jar_dir, jar), File.join(warbler_jar_dir, jar))
  end
end

def fix_json_jruby_paths(web_inf_gems)
  #TODO: Why is this necessary? Is this an appengine issue?
  puts "Fixing paths in json-jruby"
  ext = Dir[File.join(web_inf_gems, "json-jruby-*", "lib", "json", "ext.rb")].first
  if ext
    text = File.open(ext, "r") { |f| f.read }
    text.gsub!("require 'json/ext/parser'", "require 'ext/parser'")
    text.gsub!("require 'json/ext/generator'", "require 'ext/generator'")
    File.open(ext, "w") { |f| f.write(text) }
  end
end

def create_appengine_web(path, robot_name, version)
  puts "Creating appengine config file #{File.expand_path(path)}"
  File.open(path, "w") do |f|
    f.puts appengine_web_contents(robot_name, version)
  end
end

def appengine_web_contents(robot_name, version)
  <<-APPENGINE
<?xml version="1.0" encoding="utf-8"?>
<appengine-web-app xmlns="http://appengine.google.com/ns/1.0">
    <application>#{robot_name}</application>
    <version>#{version}</version>
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