require 'rubygems'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'rake/clean'
require 'fileutils'
include FileUtils

# Non-user config.
DEPS = {
    'rack' => '>=1.0',
    'builder' => '>=2.1.2',
    'json-jruby' => '>=1.1.6',
    'warbler' => '>=0.9.13'
  }

SPEC = Gem::Specification.new do |s|
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
  s.files = FileList['lib/**/*', 'bin/*']
  s.bindir = 'bin'
  s.executables = []
  s.require_path = "lib"
  s.has_rdoc = true
  DEPS.each { | name, version | s.add_runtime_dependency( name, version ) }
  s.executables = 'rave'
end

SPEC_FILE = "./pkg/#{SPEC.name}.gemspec"
GEM_FILE = "./pkg/#{SPEC.name}-#{SPEC.version}.gem"
RDOC_DIR = './doc/rdoc'

CLOBBER.include FileList['examples/*/tmp', GEM_FILE, RDOC_DIR]
CLEAN.include FileList[SPEC_FILE, 'examples/*/*.war']

Rake::GemPackageTask.new(SPEC) do |pkg|
end

# File dependencies for the gem.
task :package => Dir['lib/**/*.rb']

desc "Install gem"
task :install => GEM_FILE do
  cmd = "gem install #{GEM_FILE}"
  cmd = "jruby -S #{cmd}" if RUBY_PLATFORM == 'java'
  system cmd
end

desc "Create .gemspec file (useful for github)"
task :gemspec => SPEC_FILE
file SPEC_FILE => FileList[__FILE__, 'lib/**/*.rb'] do
  puts "Generating #{SPEC_FILE}"
  File.open(SPEC_FILE, "w") do |f|
    f.puts SPEC.to_ruby
  end
end

desc 'Publish rdoc to RubyForge (only for Diminish7).'
task :publish do
  "scp -r #{RDOC_DIR} diminish7@rubyforge.org:/var/www/gforge-projects/rave/"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = RDOC_DIR
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.add([ 'README', 'lib/models/*.rb', 'lib/ops/*.rb'])
  rdoc.title = 'Rave - A Google Wave robot client framework for Ruby'
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/test_*.rb']
end

# Synonym for backwards compatibility.
task :test => :spec

# Build and upload the provided examples.
Dir['examples/*'].each do |path|
  if File.directory? path
    path =~ /examples\/(.*)/
    dir = $1

    namespace dir do
      desc "Build #{path} archive"
      task :build => :install do
        cd path
        system "jruby -S rake build"
        cd '../..'
      end
      
      desc "Deploy examples/#{dir} as robot (requires appspot account)"
      task :deploy => :"#{dir}:build" do
        cd path
        system "jruby -S rake deploy"
        cd '../..'
      end
    end
  end
end
