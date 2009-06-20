#Runs warbler to package up the robot
# then does some cleanup that is specific to App Engine:
# => Deletes the complete JRuby jar from both the app's lib folder and
#    the frozen warbler gem, and replaces them with a broken version
# => Changes the file path json-jruby 
#    TODO: Not sure why this is necessary, but it doesn't run on appengine without it
def create_war(args)
  #Run warbler
  system("jruby -S warble")
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