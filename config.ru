require 'rubygems'
require 'sinatra'
require 'json'
require 'open-uri'
require 'timeout'

# Require locally-cached gems
require 'vendor/gems/klarlack/lib/klarlack'

# This is the address for the varnish server
VARNISH_SERVER = 'your-server:6082'

require 'varnish_bust'
run Sinatra::Application