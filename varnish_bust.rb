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
    varnish = Varnish::Client.new(VARNISH_SERVER)
    Timeout::timeout(3) do
      purge_cmds.each do |cmd|
        puts "purging '#{cmd}' on #{VARNISH_SERVER}..."
        varnish.purge cmd
      end
    end
  rescue Timeout::Error
    halt 500, "ERROR: Request to #{VARNISH_SERVER} timed out."
  rescue Exception => e
    halt 500, "ERROR: #{e.message}"
  else
    "OK. Objects purged from #{VARNISH_SERVER}."
  end
end