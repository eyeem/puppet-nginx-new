define nginx::resource::passenger (
  $listen_port,
  $ensure                       = 'enable',
  $listen_ip                    = '*',
  $listen_options               = undef,
  $ipv6_enable                  = false,
  $ipv6_listen_ip               = '::',
  $ipv6_listen_port             = '80',
  $ipv6_listen_options          = 'default',
  $root,
  $rack_env                     = 'production',
  $passenger_base_uri           = '/',
  $passenger_set_cgi_param      = [],
  $include                      = '',
  $additional_options           = [],
  $auth_basic                   = undef,
  $auth_basic_user_file         = undef,
  $server_name                  = [$name]) {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # Add IPv6 Logic Check - Nginx service will not start if ipv6 is enabled
  # and support does not exist for it in the kernel.
  if ($ipv6_enable and !$::ipaddress6) {
    warning('nginx: IPv6 support is not enabled or configured properly')
  }

  # Use the File Fragment Pattern to construct the configuration files.
  # Create the base configuration file reference.
  if ($listen_port != $ssl_port) {
    file { "${nginx::config::nx_temp_dir}/nginx.passenger.d/${name}-001":
      ensure  => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/passenger/passenger.erb'),
      notify  => Class['nginx::service'],
    }
  }

}
