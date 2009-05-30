require 'rubygems'
require 'set'

here = File.dirname(__FILE__)
models = File.join(here, "models")

require File.join(here, 'constants')

%w( blip context document event wave wavelet ).each do |dep|
  require File.join(models, dep)
end
