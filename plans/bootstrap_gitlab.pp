plan bootstrap_ze_things::bootstrap_gitlab (
  TargetSpec $targets,
  String[1] $user       = 'root',
  String[1] $password   = 'puppetlabs',
  String[1] $namespace  = 'puppet',
  String[1] $repo_name  = 'control-repo',
  String[1] $import_url = 'https://github.com/puppetlabs/control-repo.git',
  String[1] $host,
) {
  $gitlab_names = get_targets($targets).map |$n| { $n.name }

  $gitlab_names.each |$gitlab_node| {
    # install gitlab
    run_task('bootstrap_ze_things::gitlab_install', $targets, host => $host, password => $password)

    # retrieve the auth token for the user
    $atr = run_task('bootstrap_ze_things::gitlab_auth_token',
      $targets, host => $host, user => $user, password => $password)

    $access_token = $atr.to_data[0]['result']['access_token']

    # assume the group doesn't exist so create it
    $cgr = run_task('bootstrap_ze_things::gitlab_create_group',
      $targets, host => $host, group_name => $namespace, group_path => $namespace,
      access_token => $access_token)

    $namespace_id = $cgr.to_data[0]['result']['id']

    # import the specified repo into the newly created group
    run_task('bootstrap_ze_things::gitlab_project_import',
      $targets, host => $host, repo_name => $repo_name, import_url => $import_url,
      namespace_id => $namespace_id, access_token => $access_token)
  }

}
