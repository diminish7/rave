# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rave}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason Rush", "Jay Donnell"]
  s.date = %q{2009-06-17}
  s.default_executable = %q{rave}
  s.description = %q{A toolkit for building Google Wave robots in Ruby}
  s.email = %q{diminish7@gmail.com}
  s.executables = ["rave"]
  s.files = ["bin/rave", "examples/casey/appengine-web.xml", "examples/casey/config.ru", "examples/casey/robot.rb", "examples/casey/config/warble.rb", "examples/casey/lib/appengine-api-1.0-sdk-1.2.1.jar", "examples/casey/lib/jruby-core.jar", "examples/casey/lib/ruby-stdlib.jar", "lib/exceptions.rb", "lib/rave.rb", "lib/commands/create.rb", "lib/commands/server.rb", "lib/commands/usage.rb", "lib/commands/war.rb", "lib/jars/appengine-api-1.0-sdk-1.2.1.jar", "lib/jars/jruby-core.jar", "lib/jars/ruby-stdlib.jar", "lib/mixins/controller.rb", "lib/mixins/data_format.rb", "lib/models/annotation.rb", "lib/models/blip.rb", "lib/models/context.rb", "lib/models/document.rb", "lib/models/event.rb", "lib/models/operation.rb", "lib/models/robot.rb", "lib/models/wave.rb", "lib/models/wavelet.rb", "lib/ops/blip_ops.rb", "test/helper.rb", "test/test_blip.rb", "test/test_context.rb", "test/test_event.rb", "test/test_robot.rb"]
  s.homepage = %q{http://github.com/diminish7/rave}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubyforge_project = %q{rave}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A Google Wave robot client API for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0"])
      s.add_runtime_dependency(%q<builder>, [">= 2.1.2"])
      s.add_runtime_dependency(%q<json-jruby>, [">= 1.1.6"])
      s.add_runtime_dependency(%q<warbler>, [">= 0.9.13"])
    else
      s.add_dependency(%q<rack>, [">= 1.0"])
      s.add_dependency(%q<builder>, [">= 2.1.2"])
      s.add_dependency(%q<json-jruby>, [">= 1.1.6"])
      s.add_dependency(%q<warbler>, [">= 0.9.13"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0"])
    s.add_dependency(%q<builder>, [">= 2.1.2"])
    s.add_dependency(%q<json-jruby>, [">= 1.1.6"])
    s.add_dependency(%q<warbler>, [">= 0.9.13"])
  end
end
