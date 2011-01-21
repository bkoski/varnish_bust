get '/bust' do
  if ['host', 'path', 'paths'].all? { |key| params[key].nil? || params[key].length == 0 }
     halt 400, "ERROR: you must provide a 'host' param and a 'path' or comma-delimited 'paths' key"
  end
  
  host = params['host']
  
  if params['paths']
    paths = params['paths'].split(',')
  else
    paths = [params['path']]
  end 
  
  # Make sure each path begins with '/'
  paths.map! do |p|
    p.strip!
    p.insert(0,'/') if p[0,1] != '/'
    p
  end
  
  purge_cmds = paths.collect do |p|
   "req.http.host ~ #{host} && req.url ~ ^#{p}"
  end

  begin
    server = varnish_host(params['server'])
    varnish = Varnish::Client.new(server)
    Timeout::timeout(3) do
      purge_cmds.each do |cmd|
        puts "purging '#{cmd}' on #{server}..."
        # varnish.purge cmd
      end
    end
  rescue Timeout::Error
    halt 500, "ERROR: Request to #{server} timed out."
  rescue Exception => e
    halt 500, "ERROR: #{e.message}"
  else
    "OK. Objects purged from #{server}."
  end
end

private
def varnish_host(server_name)
  if defined?(VARNISH_SERVERS)
    if server_name.nil? || server_name.empty?
      addr = VARNISH_SERVERS['default']
    else
      addr = VARNISH_SERVERS[server_name]
    end
  else # for backwards-compatibility with config files
    addr = VARNISH_SERVER
  end
  
  halt 500, "ERROR: varnish server #{server_name} unknown." if addr.nil? || addr.empty?
  
  return addr
end