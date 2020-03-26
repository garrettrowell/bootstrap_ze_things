Puppet::Functions.create_function(:'bootstrap_ze_things::node_manager_config_path') do
  dispatch :nm_yaml_location do
  end

  def nm_yaml_location()
    File.join(Puppet.settings['confdir'], 'classifier.yaml')
  end
end
