# == Class: openstack_project::review_dev
#
class openstack_project::review_dev (
  $github_oauth_token = '',
  $github_project_username = '',
  $github_project_password = '',
  $mysql_host = '',
  $mysql_password = '',
  $email_private_key = '',
  $contactstore = true,
  $contactstore_appsec = '',
  $contactstore_pubkey = '',
  $ssh_dsa_key_contents = '',
  $ssh_dsa_pubkey_contents = '',
  $ssh_rsa_key_contents = '',
  $ssh_rsa_pubkey_contents = '',
  $ssh_project_rsa_key_contents = '',
  $ssh_project_rsa_pubkey_contents = '',
  $lp_sync_consumer_key = '',
  $lp_sync_token = '',
  $lp_sync_secret = '',
  $sysadmins = [],
  $swift_username = '',
  $swift_password = '',
  $project_config_repo = '',
  $projects_config = 'openstack_project/review-dev.projects.ini.erb',
) {

  realize (
    User::Virtual::Localuser['dompegam'],
  )

  class { 'project_config':
    url  => $project_config_repo,
    base => 'dev/',
  }

  class { 'openstack_project::gerrit':
    vhost_name                      => 'review-dev.openswitch.net',
    canonicalweburl                 => 'https://review-dev.openswitch.net',
    ssl_cert_file                   => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key_file                    => '/etc/ssl/private/ssl-cert-snakeoil.key',
    ssl_chain_file                  => '',
    ssh_dsa_key_contents            => $ssh_dsa_key_contents,
    ssh_dsa_pubkey_contents         => $ssh_dsa_pubkey_contents,
    ssh_rsa_key_contents            => $ssh_rsa_key_contents,
    ssh_rsa_pubkey_contents         => $ssh_rsa_pubkey_contents,
    ssh_project_rsa_key_contents    => $ssh_project_rsa_key_contents,
    ssh_project_rsa_pubkey_contents => $ssh_project_rsa_pubkey_contents,
    email                           => 'review-dev@openstack.org',
    war                             =>
      'http://tarballs.openstack.org/ci/test/gerrit-v2.9.4.3.7adc92a.war',
    contactstore                    => $contactstore,
    contactstore_appsec             => $contactstore_appsec,
    contactstore_pubkey             => $contactstore_pubkey,
    contactstore_url                =>
      'https://review-dev.openstack.org/fakestore',
    acls_dir                        => $::project_config::gerrit_acls_dir,
    notify_impact_file              => $::project_config::gerrit_notify_impact_file,
    projects_file                   => $::project_config::jeepyb_project_file,
    projects_config                 => $projects_config,
    github_username                 => 'openstack-gerrit-dev',
    github_oauth_token              => $github_oauth_token,
    github_project_username         => $github_project_username,
    github_project_password         => $github_project_password,
    mysql_host                      => $mysql_host,
    mysql_password                  => $mysql_password,
    email_private_key               => $email_private_key,
    sysadmins                       => $sysadmins,
    gitweb                          => false,
    cgit                            => true,
    web_repo_url                    => 'https://git.openswitch.net/cgit/',
    swift_username                  => $swift_username,
    swift_password                  => $swift_password,
    replication                         => [
#      {
#        name                 => 'github',
#        url                  => 'git@github.com:',
#        authGroup            => 'Anonymous Users',
#        replicationDelay     => '1',
#        replicatePermissions => false,
#        mirror               => true,
#      },
      {
        name                 => 'local',
        url                  => 'file:///opt/lib/git/',
        replicationDelay     => '1',
        threads              => '4',
        mirror               => true,
      },
      {
        name                 => 'git03',
        url                  => 'cgit@git03.openswitch.net:/var/lib/git/',
        replicationDelay     => '1',
        threads              => '4',
        mirror               => true,
      },
      {
        name                 => 'git04',
        url                  => 'cgit@git04.openswitch.net:/var/lib/git/',
        replicationDelay     => '1',
        threads              => '4',
        mirror               => true,
      },
    ],
    require                         => $::project_config::config_dir,
  }

  gerrit::plugin { 'javamelody':
    version => 'e00d5af',
  }

  package { 'python-launchpadlib':
    ensure => present,
  }
  file { '/home/gerrit2/.launchpadlib':
    ensure  => directory,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0775',
    require => User['gerrit2'],
  }
  file { '/home/gerrit2/.launchpadlib/creds':
    ensure  => present,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0600',
    content => template('openstack_project/gerrit_lp_creds.erb'),
    replace => true,
    require => User['gerrit2'],
  }

  include bup
  bup::site { 'rs-ord':
    backup_user   => 'bup-review-dev',
    backup_server => 'ci-backup-rs-ord.openstack.org',
  }
}
