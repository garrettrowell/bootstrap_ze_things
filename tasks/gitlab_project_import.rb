#!/opt/puppetlabs/puppet/bin/ruby

require "net/https"
require "uri"
require "json"

begin
  params = JSON.parse(STDIN.read)
  result = Hash.new
  uri = URI.parse("https://#{params['host']}/api/v4/projects")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  headers = {
    'Content-Type'  => 'application/json',
    'Authorization' => "Bearer #{params['access_token']}",
  }
  data = {
    'name'         => params['repo_name'],
    'import_url'   => params['import_url'],
    'namespace_id' => params['namespace_id'],
  }
  response = http.post(uri.path, data.to_json, headers)
  result = JSON.parse(response.body)
rescue Exception => e
  result[:_error] = { msg: e.message,
                      kind: "puppetlabs-example_modules/unknown",
                      details: { class: e.class.to_s },
  }
end

puts result.to_json
