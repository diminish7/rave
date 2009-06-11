require 'rubygems'
require 'rake/rdoctask' 
require 'rake/gempackagetask'
 
deps = {
    'rack' => '~>1.0'
  }

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.6'
  s.name = "rave"
  s.rubyforge_project = 'rave'
  s.version = "0.1.0"
  s.authors = ["Jason Rush", "Jay Donnell"]
  s.email = 'diminish7@gmail.com'
  s.homepage = 'http://github.com/diminish7/rave'
  s.summary = "A Google Wave API for Ruby"
  s.files = Dir['*/**/*']
  s.bindir = 'bin'
  s.executables = []
  s.require_path = "lib"
  s.has_rdoc = true
  deps.each { | name, version | s.add_runtime_dependency( name, version ) }
  s.bin_dir = 'bin'
  s.executables = 'rave'
end
 
task :package => :clean do
  Gem::Builder.new(spec).build
end
 
task :clean do
  system 'rm -rf *.gem'
end
 
task :install => :package do
  system 'sudo gem install ./*.gem'
end
 
desc "create .gemspec file (useful for github)"
task :gemspec do
  filename = "#{spec.name}.gemspec"
  File.open(filename, "w") do |f|
    f.puts spec.to_ruby
  end
end
 
desc 'Publish rdoc to RubyForge.'
task :publish do
  `scp -r doc/rdoc diminish7@rubyforge.org:/var/www/gforge-projects/rave/`
end
 
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.add([ 'README', 'lib/*.rb' ])
end
 
desc "run some tests"
task :test do
  system "ruby -S spec -c #{ Dir["test/test_*.rb"].join(" ") }"
end
 