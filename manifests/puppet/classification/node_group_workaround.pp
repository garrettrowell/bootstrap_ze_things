# @summary A short summary of the purpose of this class
#
# Create a classifer.yaml from a template.
#  This came about from: https://github.com/WhatsARanjit/puppet-node_manager/pull/49
#
# @example
#   include bootstrap_ze_things::puppet::classification::node_group_workaround
class bootstrap_ze_things::puppet::classification::node_group_workaround (
  String $master,
){

  # Create a classifier.yaml that can be used from bolt plans.
  #   Any node_group resources used should also have the following:
  #   require => File['classifier.yaml'],
  file { 'classifer.yaml':
    ensure  => file,
    mode    => '0644',
    path    => Deferred('bootstrap_ze_things::node_manager_config_path'),
    content => epp('bootstrap_ze_things/node_manager/classifier.yaml.epp', {
      server => $master,
    }),
  }
}
