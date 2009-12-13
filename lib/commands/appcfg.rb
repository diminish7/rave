#Does an appcfg update to deploy the tmp/war folder to appengine
def appcfg_update(args)
  Rake.application.standard_exception_handling do
    Rake.application.init
    Rave::Task.new
    task(:default => "rave:appcfg_update")
    Rake.application.top_level
  end
end