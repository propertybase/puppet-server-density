# Class: serverdensity
#
# This class installs and configures the Server Density monitoring agent: http://www.serverdensity.com/
#
# Notes:
#  This class is Ubuntu/Debian specific for now.
#  By Sean Porter, Gastown Labs Inc.
#
# Actions:
#  - Adds to the apt repository list
#  - Installs and configures the Server Density monitoring agent, sd-agent
#
# Sample Usage:
# class { 'serverdensity':
#   subdomain   => 'propertybase',
#   agent_key   => $::serverdensity_keys[$hostname],
#   options     => [
#     'plugin_directory: /usr/bin/sd-agent/plugins',
#     'mongodb_dbstats: yes'
#   ],
#   plugins     => [
#     {
#       'name'    => 'ElasticSearch',
#       'options' => [
#         'host: localhost:9200'
#       ]
#     }
#   ],
# }

class serverdensity (
	$subdomain,
	$agent_key = undef,
	$options = [],
	$plugins = []
){

	case $::osfamily {
    'RedHat': {
      yumrepo { 'serverdensity':
        baseurl => "http://www.serverdensity.com/downloads/linux/redhat/",
        descr => "Server Density",
        enabled => "1",
        gpgkey => "https://www.serverdensity.com/downloads/boxedice-public.key",
      }
      Yumrepo['serverdensity'] -> Package['sd-agent']
    }

    'Debian': {
      include apt
      apt::source { 'serverdensity':
        location    => 'http://www.serverdensity.com/downloads/linux/deb',
        release     => 'all',
        repos       => 'main',
        key         => '7F0CEB10',
        key_source  => 'https://www.serverdensity.com/downloads/boxedice-public.key',
        include_src => false,
      }
      Apt::Source['serverdensity'] -> Package['sd-agent']
    }
  }

  package { "sd-agent":
		ensure => installed,
	}

	file { "/etc/sd-agent/config.cfg":
		content => template("serverdensity/config.cfg.erb"),
		mode => "0644",
	}

	service { "sd-agent":
		ensure => running,
		enable => true,
	}

	Package['sd-agent'] -> File['/etc/sd-agent/config.cfg']
	File['/etc/sd-agent/config.cfg'] -> Service['sd-agent']
	File['/etc/sd-agent/config.cfg'] ~> Service['sd-agent']
	Package['sd-agent'] ~> Service['sd-agent']
}
