#!/opt/puppetlabs/puppet/bin/ruby

require "net/https"
require "uri"
require "json"

begin
  params = JSON.parse(STDIN.read)
  params = Hash.new
  uri = URI.parse("https://#{params['host']}/api/v4/groups")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  headers = {
    'Content-Type'  => 'application/json',
    'Authorization' => "Bearer #{params['access_token']}"
  }
  data = {
    'name' => params['group_name'],
    'path' => params['group_path'],
  }
  response = http.post(uri.path, data.to_json, headers)
  body_json = JSON.parse(response.body)
  result = body_json
rescue Exception => e
  result[:_error] = { msg: e.message,
                      kind: "puppetlabs-example_modules/unknown",
                      details: { class: e.class.to_s },
  }
end

puts result.to_json
