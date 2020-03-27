# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include bootstrap_ze_things::puppet::classification::code_manager
class bootstrap_ze_things::puppet::classification::code_manager (
  String $r10k_remote,
  String $r10k_private_key = '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa'
){

  include bootstrap_ze_things::puppet::classification::node_group_workaround

  # Since the `PE Master` NG exists in a default install and the
  #   `puppet_enterprise::profile::master` class is already configured,
  #   add our customizations as data.
  node_group { 'PE Master':
    data    => {
      'puppet_enterprise::profile::master' => {
        'code_manager_auto_configure' => true,
        'r10k_private_key'            => $r10k_private_key,
        'r10k_remote'                 => $r10k_remote,
      },
    },
    require => File['classifier.yaml'],
  }
}
