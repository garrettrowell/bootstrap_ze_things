#!/opt/puppetlabs/puppet/bin/ruby

require "net/https"
require "uri"
require "json"

begin
  params = JSON.parse(STDIN.read)
  result = HASH.new
  uri = URI.parse("https://#{params['gitlab_host']}/oauth/token")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  headers = {
    'Content-Type' => 'application/json',
  }
  data = {
    'grant_type' => 'password',
    'username'   => params['gitlab_user'],
    'password'   => params['gitlab_password'],
  }
  response = http.post(uri.path, data.to_json, headers)
  body_json = JSON.parse(response.body)
  result['access_token'] = body_json['access_token']
rescue Exception => e
  result[:_error] = { msg: e.message,
                      kind: "puppetlabs-example_modules/unknown",
                      details: { class: e.class.to_s },
  }
end
