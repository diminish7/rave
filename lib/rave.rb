require 'rubygems'
require 'set'
require 'builder'
require 'json'

here = File.dirname(__FILE__)
mixins = File.join(here, "mixins")
models = File.join(here, "models")

require File.join(here, 'exceptions')

%w( data_format).each do |dep|
  require File.join(mixins, dep)
end

%w( annotation blip blip_operations context document event operation robot wave wavelet).each do |dep|
  require File.join(models, dep)
end
