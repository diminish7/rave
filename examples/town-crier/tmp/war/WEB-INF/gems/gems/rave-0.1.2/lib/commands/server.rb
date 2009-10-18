#Starts up rack based on the config.ru file in the working directory
# Note that this is of limited use right now, because robots have to
# run on appengine.  Better to test locally with the appengine sdk
def start_robot(args)
  cmd = (RUBY_PLATFORM == 'java') ? "jruby -S rackup" : "rackup"
  cmd += " " + args.join(" ") if args
  exec(cmd)
end