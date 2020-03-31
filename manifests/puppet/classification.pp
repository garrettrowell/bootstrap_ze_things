# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include bootstrap_ze_things::puppet::classification
class bootstrap_ze_things::puppet::classification (
  String $r10k_remote,
  String $r10k_private_key = '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa',
  String $cd4pe_version    = '3.x',
){
  # Need to bootstrap the classifier.yaml before we can use the
  #   node_group resource
  Node_group {
    require => File['classifier.yaml'],
  }

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
  }

  # Create NG for CD4PE
  node_group { 'Continuous Delivery for PE':
    ensure               => 'present',
    classes              => {
      'cd4pe' => {
        'cd4pe_version' => $cd4pe_version,
      }
    },
    environment          => 'production',
    override_environment => false,
    parent               => 'PE Infrastructure',
  }

  # Create EG for staging environment
  node_group { 'Staging environment':
    ensure               => 'present',
    description          => 'Staging nodes',
    environment          => 'staging',
    override_environment => true,
    parent               => 'All Environments',
  }
}
