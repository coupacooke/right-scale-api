#$LOAD_PATH.unshift(File.dirname(__FILE__))
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'right-scale-api'
require 'fakeweb'
require 'rspec'
require 'rspec/autorun'

#RSpec::Runner.configure do |config|
  FakeWeb.allow_net_connect = false
#end
