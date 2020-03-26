plan bootstrap_ze_things::code_manager (
  TargetSpec $puppetmaster,
  TargetSpec $gitlab,
  String[1] $ssh_comment     = 'PE Code Manager',
  String[1] $ssh_password    = '',
  String[1] $ssh_keyfile     = '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa',
  String[1] $gitlab_user     = 'root',
  String[1] $gitlab_password = 'puppetlabs',
  String[1] $gitlab_host,
) {
    # generate key-pair on puppetmaster
    $skr = run_task('bootstrap_ze_things::ssh_keygen',
                    $puppetmaster, keyfile => $ssh_keyfile, password => $ssh_password, comment => $ssh_comment)

    $sshkey = $skr.to_data[0]['result']['public_key']

    # retrieve the auth token for the user
    $atr = run_task('bootstrap_ze_things::gitlab_auth_token',
                    $gitlab, host => $gitlab_host, user => $gitlab_user, password => $gitlab_password)

    $access_token = $atr.to_data[0]['result']['access_token']

    # add the sshkey to the users account
    run_task('bootstrap_ze_things::gitlab_add_sshkey',
             $gitlab, host => $gitlab_host, access_token => $access_token, title => $sshkey_comment, key => $sshkey)


}
