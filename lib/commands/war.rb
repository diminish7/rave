
def create_war(args)
  system("jruby -S warble")
  path = File.join(".", "tmp", "war", "WEB-INF", "lib", "jruby-complete-*.jar")
  warbler = File.join(".", "tmp", "war", "WEB-INF", "gems", "gems", "warbler-*", "lib")
  lib_dir = File.join(File.dirname(__FILE__), "..", "jars" )
  jar = Dir[path].first
  puts "Deleting #{jar}"
  File.delete(jar) if jar
  jar = Dir[File.join(warbler, "jruby-complete-*.jar")].first
  puts "Deleting #{jar}"
  File.delete(jar) if jar
  jar_dir = Dir[warbler].first
  puts "Copying jruby chunks"
  %w( jruby-core.jar ruby-stdlib.jar ).each do |jar|
    File.copy(File.join(lib_dir, jar), File.join(jar_dir, jar))
  end
end