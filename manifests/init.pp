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
# Sample Usage (Monitoring MongoDB):
#  serverdensity { "server-density-subdomain":
#    agent_key => "b82e833n4o9h189a352k8ds67725g3jy",
#    options => ["mongodb_server: localhost"],
#  }
#
class serverdensity (
	$subdomain,
	$agent_key = undef,
	$options = [],
	$plugins = {}
){
	include apt

	apt::source { 'serverdensity':
    location    => 'http://www.serverdensity.com/downloads/linux/deb',
    release     => 'all',
    repos       => 'main',
    key         => '7F0CEB10',
    key_source  => 'https://www.serverdensity.com/downloads/boxedice-public.key',
    include_src => false,
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

	Apt::Source['serverdensity'] -> Package['sd-agent']
	Package['sd-agent'] -> File['/etc/sd-agent/config.cfg']
	File['/etc/sd-agent/config.cfg'] -> Service['sd-agent']
	File['/etc/sd-agent/config.cfg'] ~> Service['sd-agent']
	Package['sd-agent'] ~> Service['sd-agent']
}
