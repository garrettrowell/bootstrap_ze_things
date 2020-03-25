plan bootstrap_ze_things::bootstrap_gitlab (
  TargetSpec $targets,
  String[1] $user,
  String[1] $password,
  String[1] $namespace,
) {
  $gitlab_name = get_targets($targets).map |$n| { $n.name }
  $token_result = run_task('bootstrap_ze_things::gitlab_auth_token', $targets, host    => $gitlab_name, user => $user, password => $password)
  $create_result = run_task('bootstrap_ze_things::gitlab_create_group', $targets, host => $gitlab_name, group_name => $namespace, group_path => $namespace, access_token => $token_result.to_data['result']['access_token'])
  #  bootstrap_ze_things::gitlab_auth_token       Request a gitlab auth token
  #bootstrap_ze_things::gitlab_create_group     Create a gitlab group
  #bootstrap_ze_things::gitlab_project_import   Create a gitlab group
  #bootstrap_ze_things::install_gitlab          A short description of this task
}
