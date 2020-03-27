plan bootstrap_ze_things::code_manager (
  TargetSpec $puppetmaster,
  TargetSpec $gitlab,
  String[1]  $ssh_comment     = 'PE_Code_Manager',
  String     $ssh_password    = '',
  String[1]  $ssh_keyfile     = '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa',
  String[1]  $gitlab_user     = 'root',
  String[1]  $gitlab_password = 'puppetlabs',
  String[1]  $gitlab_host,
  String[1]  $r10k_remote     = 'git@gitlab.puppetdebug.vlan:puppet/control-repo.git',
) {

  # generate key-pair on puppetmaster
  $skr = run_task('bootstrap_ze_things::ssh_keygen', $puppetmaster, keyfile => $ssh_keyfile, password => $ssh_password, comment => $ssh_comment)

  $sshkey = $skr.to_data[0]['result']['public_key']

  # retrieve the auth token for the user
  $atr = run_task('bootstrap_ze_things::gitlab_auth_token', $gitlab, host => $gitlab_host, user => $gitlab_user, password => $gitlab_password)

  $access_token = $atr.to_data[0]['result']['access_token']

  # add the sshkey to the users account
  run_task('bootstrap_ze_things::gitlab_add_sshkey', $gitlab, host => $gitlab_host, access_token => $access_token, title => $ssh_comment, key => $sshkey)

  # Do some hacky bs to get node_group to work on master
  $puppetmaster.apply_prep
  apply($puppetmaster) {
    class { 'bootstrap_ze_things::puppet::classification::node_group_workaround':
      master => 'master.puppetdebug.vlan',
    }

    class { 'bootstrap_ze_things::puppet::classification::code_manager':
      r10k_remote      => $r10k_remote,
      r10k_private_key => $ssh_keyfile,
    }

    #    file { 'classifier.yaml':
    #      ensure  => file,
    #      mode    => '0644',
    #      path    => Deferred('bootstrap_ze_things::node_manager_config_path'),
    #      content => epp('bootstrap_ze_things/node_manager/classifier.yaml.epp', {
    #        server => 'master.puppetdebug.vlan',
    #        }),
    #    }
    #
    #
    #    node_group { 'PE Master':
    #      data    => {
    #        'puppet_enterprise::profile::master' =>  {
    #          'code_manager_auto_configure' => true,
    #          'r10k_private_key'            => '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa',
    #          'r10k_remote'                 => 'git@gitlab.puppetdebug.vlan:puppet/control-repo.git',
    #        }
    #      },
    #      require => File['classifier.yaml'],
    #    }
  }
}
