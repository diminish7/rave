require 'rubygems'
require 'set'
require 'builder'
require 'json'

here = File.dirname(__FILE__)
mixins = File.join(here, "mixins")
models = File.join(here, "models")
ops = File.join(here, "ops")

require File.join(here, 'exceptions')

%w( data_format controller time_utils ).each do |dep|
  require File.join(mixins, dep)
end

%w( annotation blip context document event operation range robot wave wavelet user).each do |dep|
  require File.join(models, dep)
end

%w( blip_ops ).each do |dep|
  require File.join(ops, dep)
end