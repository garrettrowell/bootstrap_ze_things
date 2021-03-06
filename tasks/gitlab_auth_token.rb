#!/opt/puppetlabs/puppet/bin/ruby

require "net/https"
require "uri"
require "json"

begin
  params = JSON.parse(STDIN.read)
  result = Hash.new
  uri = URI.parse("https://#{params['host']}/oauth/token")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  headers = {
    'Content-Type' => 'application/json',
  }
  data = {
    'grant_type' => 'password',
    'username'   => params['user'],
    'password'   => params['password'],
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
