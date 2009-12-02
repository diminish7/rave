require 'rubygems'
require 'rake/rdoctask' 
require 'rake/gempackagetask'
 
deps = {
    'rack' => '>=1.0',
    'builder' => '>=2.1.2',
    'json-jruby' => '>=1.1.6',
    'warbler' => '>=0.9.13'
  }

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.6'
  s.name = "rave"
  s.rubyforge_project = 'rave'
  s.version = "0.1.2"
  s.authors = ["Jason Rush", "Jay Donnell"]
  s.email = 'diminish7@gmail.com'
  s.homepage = 'http://github.com/diminish7/rave'
  s.summary = "A Google Wave robot client API for Ruby"
  s.description = "A toolkit for building Google Wave robots in Ruby"
  s.files = Dir['lib/**/*'] + Dir['bin/*']
  s.bindir = 'bin'
  s.executables = []
  s.require_path = "lib"
  s.has_rdoc = true
  deps.each { | name, version | s.add_runtime_dependency( name, version ) }
  s.executables = 'rave'
end

desc "Build gem from gemspec"
task :gem => [:gemspec, :clean] do
  Gem::Builder.new(spec).build
end

task :package => :gem

desc "Remove gem"
task :clean do
  Dir['*.gem'].each do |file|
    File.unlink file
  end
end

desc "Install gem"
task :install => :package do
  cmd = "gem install ./*.gem"
  cmd = "jruby -S " + cmd if RUBY_PLATFORM == 'java'
  system cmd
end
 
desc "Create .gemspec file (useful for github)"
task :gemspec do
  filename = "#{spec.name}.gemspec"
  File.open(filename, "w") do |f|
    f.puts spec.to_ruby
  end
end
 
desc 'Publish rdoc to RubyForge (only works for Diminish7).'
task :publish do
  `scp -r doc/rdoc diminish7@rubyforge.org:/var/www/gforge-projects/rave/`
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.add([ 'README', 'lib/**/*.rb' ])
end
 
desc "Run some rspec tests"
task :test do
  system "ruby -S spec -c #{ Dir["test/**/test_*.rb"].join(" ") }"
end
 
