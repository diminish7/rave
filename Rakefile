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
    'warbler' => '>=0.9.13',
    'RedCloth' => '>=4.2.2'
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

NAME = "#{SPEC.name}-#{SPEC.version}"

PACKAGE_DIR = './pkg'
SPEC_FILE = "#{PACKAGE_DIR}/#{SPEC.name}.gemspec"
GEM_FILE = "#{PACKAGE_DIR}/#{NAME}.gem"

RDOC_DIR = './doc/rdoc'

RELEASE_DIR = './release'

RELEASE_FILE = "#{RELEASE_DIR}/#{NAME}.7z"
RELEASE_TMP_DIR = "#{RELEASE_DIR}/tmp/#{NAME}"

CLOBBER.include FileList[GEM_FILE, RDOC_DIR, RELEASE_FILE]
CLEAN.include FileList[SPEC_FILE, RELEASE_TMP_DIR]

Rake::GemPackageTask.new(SPEC) do |pkg|
end

# File dependencies for the gem.
task :package => Dir['lib/**/*.rb']

# TODO: How do we tell is the package is newer than the gem installed?
file GEM_FILE => :package
desc "Install gem package"
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
  t.spec_files = FileList['spec/**/*_spec.rb']
end

# Synonym for backwards compatibility.
task :test => :spec

example_tasks = {
  :build =>   { :desc => "Build WAR file", :depend => [:install] },
  :deploy =>  { :desc => "Deploy",         :depend => [:install] },
  :spec =>    { :desc => "Run specs",      :depend => [] },
  :clobber => { :desc => "Clobber files",  :depend => [] },
  :clean =>   { :desc => "Clean files",    :depend => [] },
}
examples = []
# Run rake tasks on the example robots individually.
FileList['examples/*/Rakefile'].each do |rakefile|
  path = File.dirname(rakefile)
  example = File.basename(path)
  examples << example

  namespace example do
    example_tasks.each_pair do |t, data|
      desc "#{data[:desc]} for #{example} robot"
      task t => data[:depend] do
        cd path do
          "jruby -S rake #{t}"
        end
      end
    end
  end
end

# Perform tasks for all robots at once.
namespace :examples do
  example_tasks.each_pair do |t, data|
    desc "#{data[:desc]} for all example robots"
    task t => examples.map {|e| :"#{e}:#{t}" }
  end
end

# Include example robot tasks in our general ones.
[:spec, :clobber, :clean].each do |t|
  task t => :"examples:#{t}"
end

file RELEASE_FILE => [:package, :gemspec, :rdoc]
desc "Generate #{RELEASE_FILE}"
task :release => RELEASE_FILE do
  mkdir_p RELEASE_DIR
  mkdir_p RELEASE_TMP_DIR
  %w(doc lib bin pkg spec examples README MIT-LICENSE Rakefile).each do |dir|
    cp_r dir, RELEASE_TMP_DIR
  end
  rm RELEASE_FILE if File.exist? RELEASE_FILE

  puts "\nPacking file (#{RELEASE_FILE})..."
  %x(7z a #{RELEASE_FILE} #{RELEASE_TMP_DIR})
  puts "Release file (#{RELEASE_FILE}) created."
end
