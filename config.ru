require 'rubygems'
require 'sinatra'
require 'json'
require 'open-uri'
require 'timeout'

rack_env = ENV['RACK_ENV'] || 'production'

# Setup vendored library paths
Dir.glob(File.join(File.dirname(__FILE__), "vendor", "*", "lib")).each{ |vendor| $:.unshift << vendor }
require 'klarlack'

# This file should include a constant, VARNISH_SERVERS, with a hash of server-name => server-address.
# By default, purge requests will be sent to the "default" server; if requests include a server=some-other-server
# param, the corresponding address will be used.
begin
	require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'shared', 'varnish_config'))
rescue LoadError
	VARNISH_SERVERS = { 'default' => '127.0.0.1' }
end

# Set up log file
log = File.new("log/#{rack_env}.log", "a") # This will make a nice sinatra log along side your apache access and error logs
STDOUT.reopen(log)
STDERR.reopen(log)


require 'varnish_bust'
run Sinatra::Application