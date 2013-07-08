# Class: nginx::package::debian
#
# This module manages NGINX package installation on debian based systems
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::package::debian {
  $operatingsystem_lowercase = inline_template('<%= operatingsystem.downcase %>')

  anchor { 'nginx::apt_repo' : }

  if $::nginx::passenger == true and $::operatingsystem == 'Ubuntu' {
    apt::ppa { 'ppa:brightbox/passenger-nginx': }
    $nx_package = 'nginx-extras'
  } elsif $::nginx::passenger == true and $::operatingsystem == 'Debian' {
    apt::source { 'dotdeb':
      ensure     => present,
      location   => 'http://packages.dotdeb.org',
      release    => $::lsbdistcodename,
      repos      => 'all',
      key_server => 'keys.gnupg.net',
      key        => '89DF5277'
    }
    $nx_package = 'nginx-extras'
  } else {
    apt::source { 'nginx':
      ensure     => present,
      location   => "http://nginx.org/packages/${operatingsystem_lowercase}/",
      release    => $::lsbdistcodename,
      repos      => 'nginx',
      key        => '7BD9BF62',
      key_source => 'http://nginx.org/keys/nginx_signing.key',
      before     => Anchor['nginx::apt_repo']
    }
    $nx_package = 'nginx'
  }

  package { 'nginx':
    name    => $nx_package,
    ensure  => present,
    require => Anchor['nginx::apt_repo'],
  }

}
