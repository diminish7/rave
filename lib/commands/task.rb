require 'rake'
require 'rake/tasklib'
require 'fileutils'
require 'yaml'
require 'warbler'

module Rave
  class Task < Warbler::Task

    REQUIRED_GEMS = ["rave", "json-jruby", "rack", "builder", "RedCloth"]

    def initialize
      warbler_config = Warbler::Config.new do |config|
        config.gems = ((robot_config['gems'] || []) + REQUIRED_GEMS).uniq
        config.includes = %w( robot.rb config.yaml )
      end
      super(:rave, warbler_config)
      define_post_war_processes
      define_deploy_task
    end

  private

    def robot_config
      @robot_config ||= YAML::load(File.open(File.join(".", "config.yaml")))
    end

    def define_post_war_processes
      namespace :rave do
        desc "Post-War cleanup"
        task :create_war  => 'rave' do
          #TODO: This needs to only run through this if the files have changed
          #Get config info
          web_inf = File.join(".", "tmp", "war", "WEB-INF")
          rave_jars = File.join(File.dirname(__FILE__), "..", "jars")
          #Cleanup unneeded gems that warbler copies in
          cleanup_gems(File.join(web_inf, "gems", "gems"), robot_config['gems'] || [])
          #Copy the appengine sdk jar to the robot
          copy_appengine_jar_to_robot(rave_jars, File.join(web_inf, "lib"))
          #Fix the broken paths in json-jruby
          fix_json_jruby_paths(File.join(web_inf, "gems", "gems"))
          #Add the appengine-web.xml file
          robot_name = robot_config['robot']['id'].gsub(/@.+/, '')
          version = robot_config['appcfg'] && robot_config['appcfg']['version'] ? robot_config['appcfg']['version'] : 1
          create_appengine_web(File.join(web_inf, "appengine-web.xml"), robot_name, version)
        end
      end
    end

    def define_deploy_task
      namespace :rave do
        desc "Deploy to Appengine"
        task :appcfg_update => :create_war do
          staging_folder = File.join(".", "tmp", "war")
          sdk_path = find_sdk
          if sdk_path
            appcfg_jar = File.expand_path(File.join(sdk_path, 'lib', 'appengine-tools-api.jar'))
            require appcfg_jar
            Java::ComGoogleAppengineToolsAdmin::AppCfg.main(["update", staging_folder].to_java(:string))
          else
            puts "Unable to find the Google Appengine Java SDK"
            puts "You can either"
            puts "1. Define the path to the main SDK folder in config.yaml - e.g.:"
            puts "appcfg:"
            puts "  sdk: /usr/local/appengine-java-sdk/"
            puts "2. Add the SDK bin folder to your PATH, or"
            puts "3. Create an environment variable APPENGINE_JAVA_SDK that defines the path to the main SDK folder"
          end
        end
      end
    end

    #Remove warbler and jruby-jars - added by warbler but unneeded
    def cleanup_gems(gem_dir, gems)
      ["warbler", "jruby-jars"].each do |g|
        dir = Dir[File.join(gem_dir, "#{g}*")].first
        unless dir.nil? || gems.include?(g)
          puts "Removing #{g} from war"
          FileUtils.rm_rf(dir)
        end
      end
    end

    def copy_appengine_jar_to_robot(rave_jar_dir, warbler_jar_dir)
      jar = "appengine-api-1.0-sdk-1.3.0.jar"
      rave_jar = File.join(rave_jar_dir, jar)
      warbler_jar = File.join(warbler_jar_dir, jar)
      puts "Copying appengine jar from #{rave_jar} to #{warbler_jar}"
      File.copy(rave_jar, warbler_jar)
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

    def find_sdk
      unless @sdk_path
        @sdk_path = robot_config['appcfg']['sdk'] if robot_config['appcfg'] && robot_config['appcfg']['sdk'] # Points at main SDK dir.
        @sdk_path ||= ENV['APPENGINE_JAVA_SDK'] # Points at main SDK dir.
        unless @sdk_path
          # Check everything in the PATH, which would point at the bin directory in the SDK.
          ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
            if File.exists?(File.join(path, "appcfg.sh")) or File.exists?(File.join("appcfg.cmd"))
              @sdk_path = File.dirname(path)
              break
            end
          end
        end
      end
      @sdk_path
    end

  end
end