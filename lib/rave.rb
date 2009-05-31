require 'rubygems'
require 'set'

here = File.dirname(__FILE__)
mixins = File.join(here, "mixins")
models = File.join(here, "models")

%w( unique_id ).each do |dep|
  require File.join(mixins, dep)
end

%w( blip context document event wave wavelet ).each do |dep|
  require File.join(models, dep)
end