get '/bust' do
  if params['hashes'].present?
    hashes_to_purge = params['hashes'].split(',')
  elsif params['host'].present? && params['paths'].present?
    hashes_to_purge = paths.split(',').collect { |path| "#{params['host']}##{path}" }
  else
    halt 400, "ERROR: you must provide either a 'hashes' param or 'host' and 'path'"
  end

  begin
    varnish = Varnish::Client.new(VARNISH_SERVER)
    Timeout::timeout(3) do
      hashes_to_purge.each do |h|
        varnish.purge :hash, h
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