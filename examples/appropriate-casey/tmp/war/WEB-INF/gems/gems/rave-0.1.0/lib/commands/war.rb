
def create_war(args)
  exec("jruby -S warble")
  #TODO - delete jruby-complete from both warbler and tmp/war
  #Get rid of the complete jruby jar (should already have two, broken down small enough for appengine)
  path = File.join(".", "tmp", "war", "WEB-INF", "lib", "jruby-complete-*.jar")
  jar = Dir[path].first
  puts "Deleting #{jar}"
  File.delete(jar) if jar
end