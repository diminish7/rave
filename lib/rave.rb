require 'rubygems'
require 'builder'
require 'json'
require 'redcloth'

here = File.dirname(__FILE__)
ext = File.join(here, "ext")
mixins = File.join(here, "mixins")
models = File.join(here, "models")
ops = File.join(here, "ops")

require File.join(here, 'exceptions')

%w( logger ).each do |dep|
  require File.join(ext, dep)
end

%w( logger data_format controller time_utils object_factory ).each do |dep|
  require File.join(mixins, dep)
end

%w( component user annotation blip context document event operation range robot wave wavelet element).each do |dep|
  require File.join(models, dep)
end

%w( blip_ops ).each do |dep|
  require File.join(ops, dep)
end