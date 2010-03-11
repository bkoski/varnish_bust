require 'rubygems'
require 'sinatra'
require 'json'
require 'open-uri'
require 'timeout'

rack_env = ENV['RACK_ENV'] || 'production'

# Setup vendored library paths
Dir.glob(File.join(File.dirname(__FILE__), "vendor", "*", "lib")).each{ |vendor| $:.unshift << vendor }
require 'klarlack'

# This is the address for the varnish server
begin
	require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'shared', 'varnish_config'))
rescue LoadError
	VARNISH_SERVER = 'localhost:6082'
end

# Set up log file
log = File.new("log/#{rack_env}.log", "a") # This will make a nice sinatra log along side your apache access and error logs
STDOUT.reopen(log)
STDERR.reopen(log)


require 'varnish_bust'
run Sinatra::Application