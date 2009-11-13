

get '/bust' do
  halt 400, "ERROR: no urls param provided" if request.params['urls'].nil? || request.params['urls'].empty?

  begin
    varnish = Varnish::Client.new(VARNISH_SERVER)
    urls = params['urls'].split(',')
    Timeout::timeout(3) do
      urls.each do |url|
        varnish.purge :url, params[url]
      end
    end
  rescue Timeout::Error
    halt 500, "ERROR: Request to #{VARNISH_SERVER} timed out."
  rescue Exception => e
    halt 500, "ERROR: #{e.message}"
  else
    "OK. #{urls.length} objects purged from #{VARNISH_SERVER}."
  end
end