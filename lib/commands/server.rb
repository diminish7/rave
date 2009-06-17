
def start_robot(args)
  cmd = (RUBY_PLATFORM == 'java') ? "jruby -S rackup" : "rackup"
  cmd += " " + args.join(" ") if args
  exec(cmd)
end