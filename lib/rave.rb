require 'rubygems'
require 'set'

here = File.dirname(__FILE__)
mixins = File.join(here, "mixins")
models = File.join(here, "models")

require File.join(here, 'exceptions')

%w( unique_id ).each do |dep|
  require File.join(mixins, dep)
end

%w( blip context document event operation robot wave wavelet ).each do |dep|
  require File.join(models, dep)
end
