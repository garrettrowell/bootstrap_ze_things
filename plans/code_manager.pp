plan bootstrap_ze_things::code_manager (
  TargetSpec $puppetmaster,
  TargetSpec $gitlab,
  String[1]  $ssh_comment     = 'PE_Code_Manager',
  String     $ssh_password    = '',
  String[1]  $ssh_keyfile     = '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa',
  String[1]  $gitlab_user     = 'root',
  String[1]  $gitlab_password = 'puppetlabs',
  String[1]  $r10k_remote     = 'git@gitlab.puppetdebug.vlan:puppet/control-repo.git',
) {

  # collect facts for our nodes
  run_plan(facts, targets => $gitlab)
  run_plan(facts, targets => $puppetmaster)

  # individual targets
  $gitlab_target = get_target($gitlab)
  $master_target = get_target($puppetmaster)

  # FQDN Hash
  fqdns = {
    'master' => $master_target.facts['networking']['fqdn'],
    'gitlab' => $gitlab_target.facts['networking']['fqdn'],
  }

  # generate key-pair on puppetmaster
  $skr = run_task('bootstrap_ze_things::ssh_keygen', $master_target, keyfile => $ssh_keyfile, password => $ssh_password, comment => $ssh_comment)

  $sshkey = $skr.to_data[0]['result']['public_key']

  # retrieve the auth token for the user
  $atr = run_task('bootstrap_ze_things::gitlab_auth_token', $gitlab_target, host => $fqdns['gitlab'], user => $gitlab_user, password => $gitlab_password)

  $access_token = $atr.to_data[0]['result']['access_token']

  # add the sshkey to the users account
  run_task('bootstrap_ze_things::gitlab_add_sshkey', $gitlab_target, host => $fqdns['gitlab'], access_token => $access_token, title => $ssh_comment, key => $sshkey)

  $master_target.apply_prep
  apply($master_target) {

    file { 'classifier.yaml':
      ensure  => file,
      mode    => '0644',
      path    => Deferred('bootstrap_ze_things::node_manager_config_path'),
      content => epp('bootstrap_ze_things/node_manager/classifier.yaml.epp', {
        server => $fqdns['master'],
      }),
    }

    class { 'bootstrap_ze_things::puppet::classification':
      r10k_remote      => $r10k_remote,
      r10k_private_key => $ssh_keyfile,
      require          => File['classifier.yaml'],
    }

  }
}
