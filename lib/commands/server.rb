
def start_robot(args)
  #TODO: Don't assume jruby (although it's always jruby right now because of appengine)
  cmd = "jruby -S rackup"
  cmd += " " + args.join(" ") if args
  exec(cmd)
end