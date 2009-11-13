require 'rubygems'
require 'sinatra'
require 'json'
require 'open-uri'
require 'timeout'

# Setup vendored library paths
Dir.glob(File.join(File.dirname(__FILE__), "vendor", "*", "lib")).each{ |vendor| $:.unshift << vendor }

# This is the address for the varnish server
VARNISH_SERVER = 'your-server:6082'

require 'varnish_bust'
run Sinatra::Application