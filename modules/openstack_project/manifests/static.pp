# == Class: openstack_project::static
#
class openstack_project::static (
  $sysadmins = [],
  $swift_authurl = '',
  $swift_user = '',
  $swift_key = '',
  $swift_tenant_name = '',
  $swift_region_name = '',
  $swift_default_container = '',
  $project_config_repo = '',
) {

  class { 'openstack_project::server':
    iptables_public_tcp_ports => [22, 80, 443],
    sysadmins                 => $sysadmins,
  }

#  class { 'project_config':
#    url  => $project_config_repo,
#  }

  include openstack_project
  class { 'jenkins::jenkinsuser':
    ssh_key => $openstack_project::jenkins_ssh_key,
  }

  include apache

  a2mod { 'rewrite':
    ensure => present,
  }
  a2mod { 'proxy':
    ensure => present,
  }
  a2mod { 'proxy_http':
    ensure => present,
  }

  if ! defined(File['/srv/static']) {
    file { '/srv/static':
      ensure => directory,
    }
  }

  ###########################################################
  # Archive

  apache::vhost { 'openswitch.net':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/www',
    require  => File['/srv/static/www'],
    serveraliases => ['www.openswitch.net'],
  }

  file { '/srv/static/www':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Archive

  apache::vhost { 'archive.openswitch.net':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/archive',
    require  => File['/srv/static/archive'],
  }

  file { '/srv/static/archive':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # sstate

  apache::vhost { 'sstate.openswitch.net':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/sstate',
    require  => File['/srv/static/sstate'],
  }

  file { '/srv/static/sstate':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Logs

#  apache::vhost { 'logs.openstack.org':
#    port     => 80,
#    priority => '50',
#    docroot  => '/srv/static/logs',
#    require  => File['/srv/static/logs'],
#    template => 'openstack_project/logs.vhost.erb',
#  }
#
#  apache::vhost { 'logs-dev.openstack.org':
#    port     => 80,
#    priority => '51',
#    docroot  => '/srv/static/logs',
#    require  => File['/srv/static/logs'],
#    template => 'openstack_project/logs-dev.vhost.erb',
#  }
#
#  file { '/srv/static/logs':
#    ensure  => directory,
#    owner   => 'jenkins',
#    group   => 'jenkins',
#    require => User['jenkins'],
#  }
#
#  file { '/srv/static/logs/robots.txt':
#    ensure  => present,
#    owner   => 'root',
#    group   => 'root',
#    mode    => '0444',
#    source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
#    require => File['/srv/static/logs'],
#  }
#
#  package { 'keyring':
#    ensure   => 'latest',
#    provider => 'pip',
#  }
#
#  vcsrepo { '/opt/os-loganalyze':
#    ensure   => latest,
#    provider => git,
#    revision => 'master',
#    source   => 'https://git.openstack.org/openstack-infra/os-loganalyze',
#    require  => Package['keyring'],
#  }
#
#  exec { 'install_os-loganalyze':
#    command     => 'python setup.py install',
#    cwd         => '/opt/os-loganalyze',
#    path        => '/bin:/usr/bin',
#    refreshonly => true,
#    subscribe   => Vcsrepo['/opt/os-loganalyze'],
#  }
#
#  file { '/etc/os_loganalyze':
#    ensure  => directory,
#    owner   => 'root',
#    group   => 'root',
#    mode    => '0755',
#    require => Vcsrepo['/opt/os-loganalyze'],
#  }
#
#  file { '/etc/os_loganalyze/wsgi.conf':
#    ensure  => present,
#    owner   => 'root',
#    group   => 'www-data',
#    mode    => '0440',
#    content => template('openstack_project/os-loganalyze-wsgi.conf.erb'),
#    require => File['/etc/os_loganalyze'],
#  }
#
#  file { '/srv/static/logs/help':
#    ensure  => directory,
#    recurse => true,
#    purge   => true,
#    force   => true,
#    owner   => 'root',
#    group   => 'root',
#    mode    => '0755',
#    source  => 'puppet:///modules/openstack_project/logs/help',
#    require => File['/srv/static/logs'],
#  }
#
#  file { '/usr/local/sbin/log_archive_maintenance.sh':
#    ensure => present,
#    owner  => 'root',
#    group  => 'root',
#    mode   => '0744',
#    source => 'puppet:///modules/openstack_project/log_archive_maintenance.sh',
#  }
#
#  cron { 'gziprmlogs':
#    user        => 'root',
#    minute      => '0',
#    hour        => '7',
#    weekday     => '6',
#    command     => 'bash /usr/local/sbin/log_archive_maintenance.sh',
#    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
#    require     => File['/usr/local/sbin/log_archive_maintenance.sh'],
#  }
#
  ###########################################################
  # Docs-draft

  apache::vhost { 'docs-draft.openswitch.net':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/docs-draft',
    require  => File['/srv/static/docs-draft'],
  }

  file { '/srv/static/docs-draft':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  file { '/srv/static/docs-draft/robots.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    require => File['/srv/static/docs-draft'],
  }

  ###########################################################
  # Security

#  apache::vhost { 'security.openswitch.net':
#    port     => 80,
#    priority => '50',
#    docroot  => '/srv/static/security',
#    require  => File['/srv/static/security'],
#  }
#
#  file { '/srv/static/security':
#    ensure  => directory,
#    owner   => 'jenkins',
#    group   => 'jenkins',
#    require => User['jenkins'],
#  }
#
  ###########################################################
  # Governance

  apache::vhost { 'governance.openswitch.net':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/governance',
    require  => File['/srv/static/governance'],
  }

  file { '/srv/static/governance':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Docs

  apache::vhost { 'docs.openswitch.net':
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/docs',
    require  => File['/srv/static/docs'],
  }

  file { '/srv/static/docs':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  ###########################################################
  # Specs

#  apache::vhost { 'specs.openstack.org':
#    port     => 80,
#    priority => '50',
#    docroot  => '/srv/static/specs',
#    require  => File['/srv/static/specs'],
#  }
#
#  file { '/srv/static/specs':
#    ensure  => directory,
#    owner   => 'jenkins',
#    group   => 'jenkins',
#    require => User['jenkins'],
#  }
#
#  ###########################################################
#  # legacy summit.openstack.org site redirect
#
#  apache::vhost { 'summit.openstack.org':
#    port          => 80,
#    priority      => '50',
#    docroot       => 'MEANINGLESS_ARGUMENT',
#    template      => 'openstack_project/summit.vhost.erb',
#  }
#
#  ###########################################################
#  # legacy devstack.org site redirect
#
#  apache::vhost { 'devstack.org':
#    port          => 80,
#    priority      => '50',
#    docroot       => 'MEANINGLESS_ARGUMENT',
#    serveraliases => ['*.devstack.org'],
#    template      => 'openstack_project/devstack.vhost.erb',
#  }
}
