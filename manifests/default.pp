class nginx-php-mongo {
	
	host {'self':
		ensure       => present,
		name         => $fqdn,
		host_aliases => ['puppet', $hostname],
		ip           => $ipaddress,
	}
	
	$php = ["php-fpm", "php-cli", "php-devel", "php-gd", "php-pear", "php-pecl-apc", "php-mcrypt", "php-pecl-xdebug", "php-pecl-sqlite"]

	exec { 'yum -y update':
	  	command => '/usr/bin/yum -y update',
		before => [Package["nginx"],  Package["mongo-10gen-server"], Package["mongo-10gen"], Package[$php]],
	}
	
	package { "nginx":
		ensure => present,
	}
	
	package { "mongo-10gen":
		ensure => present,
	}

	package { "mongo-10gen-server":
		ensure => present,
	}
	
	package { $php:
		notify => Service['php-fpm'],
		ensure => latest,
	}
	
	exec { 'pecl install mongo':
		notify => Service["php-fpm"],
		command => '/usr/bin/pecl install --force mongo',
		logoutput => "on_failure",
		require => [ Package[$php]],
		before => [File['/etc/php/cli/php.ini'], File['/etc/php/fpm/php.ini'], File['/etc/php/fpm/php-fpm.conf'], File['/etc/php/fpm/pool.d/www.conf']],
		unless => "/usr/bin/php -m | grep mongo",
	}
	
	exec { 'pear config-set auto_discover 1':
		command => '/usr/bin/pear config-set auto_discover 1',
		before => Exec['pear install pear.phpunit.de/PHPUnit'],
		require => Package[$php],
		unless => "/bin/ls -l /usr/bin/ | grep phpunit",
	}
	
	exec { 'pear install pear.phpunit.de/PHPUnit':
		notify => Service["php-fpm"],
		command => '/usr/bin/pear install --force pear.phpunit.de/PHPUnit',
		before => [File['/etc/php/cli/php.ini'], File['/etc/php/fpm/php.ini'], File['/etc/php/fpm/php-fpm.conf'], File['/etc/php/fpm/pool.d/www.conf']],
		unless => "/bin/ls -l /usr/bin/ | grep phpunit",
	}
	
	file { '/etc/php/cli/php.ini':
		owner  => root,
		group  => root,
		ensure => file,
		mode   => 644,
		source => '/vagrant/files/php/cli/php.ini',
		require => Package[$php],
	}
	
	file { '/etc/php/fpm/php.ini':
		notify => Service["php-fpm"],
		owner  => root,
		group  => root,
		ensure => file,
		mode   => 644,
		source => '/vagrant/files/php/fpm/php.ini',
		require => Package[$php],
	}
	
	file { '/etc/php/fpm/php-fpm.conf':
		notify => Service["php-fpm"],
		owner  => root,
		group  => root,
		ensure => file,
		mode   => 644,
		source => '/vagrant/files/php/fpm/php-fpm.conf',
		require => Package[$php],
	}
	
	file { '/etc/php/fpm/pool.d/www.conf':
		notify => Service["php-fpm"],
		owner  => root,
		group  => root,
		ensure => file,
		mode   => 644,
		source => '/vagrant/files/php/fpm/pool.d/www.conf',
		require => Package[$php],
	}
	
	file { '/etc/nginx/conf.d/default.conf':
		owner  => root,
		group  => root,
		ensure => file,
		mode   => 644,
		source => '/vagrant/files/nginx/default.conf',
		require => Package["nginx"],
	}
	
	service { "php-fpm":
	  ensure => running,
	  require => Package["php-fpm"],
	}
	
	service { "nginx":
	  ensure => running,
	  require => Package["nginx"],
	}
	
	service { "mongod":
	  ensure => running,
	  require => Package["mongo-10gen-server"],
	}
	yumrepo { "10gen":
		baseurl => "http://downloads-distro.mongodb.org/repo/redhat/os/x86_64",
	    descr => "10gen Repository",
		before => [Package["nginx"], Package["mongo-10gen-server"], Package["mongo-10gen"], Package[$php]],
	    enabled => 1,
	    gpgcheck => 0,
    }

	yumrepo { "epel-repo":
		mirrorlist => "https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=x86_64",
	    descr => "Extra Packages for Enterprise Linux 6",
		before => [Package["nginx"],  Package["mongo-10gen-server"], Package["mongo-10gen"], Package[$php]],
	    enabled => 1,
	    gpgcheck => 0,
    }

    yumrepo   { "remi-repo":
	    mirrorlist => "http://rpms.famillecollet.com/enterprise/6/remi/mirror",
	    descr => "Les RPM de remi pour Enterprise Linux 6",
		before => [Package["nginx"],  Package["mongo-10gen-server"], Package["mongo-10gen"], Package[$php]],
	    enabled => 1,
	    gpgcheck => 0,
	}

	yumrepo   { "remi-test-repo":
	    mirrorlist => "http://rpms.famillecollet.com/enterprise/6/test/mirror",
	    descr => "Les RPM de remi en test pour Enterprise Linux 6",
		before => [Package["nginx"],  Package["mongo-10gen-server"], Package["mongo-10gen"], Package[$php]],
	    enabled => 1,
	    gpgcheck => 0,
	}
}
	
include nginx-php-mongo
