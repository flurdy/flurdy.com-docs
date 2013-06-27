CREATE TABLE `aliases` (
  `pkid` smallint(3) NOT NULL auto_increment,
  `mail` varchar(120) NOT NULL default '',
  `destination` varchar(120) NOT NULL default '',
  `enabled` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`pkid`),
  UNIQUE KEY `mail` (`mail`)
) ;

CREATE TABLE `domains` (
  `pkid` smallint(6) NOT NULL auto_increment,
  `domain` varchar(120) NOT NULL default '',
  `transport` varchar(120) NOT NULL default 'virtual:',
  PRIMARY KEY  (`pkid`)
) ;

CREATE TABLE `users` (
  `id` varchar(128) NOT NULL default '',
  `crypt` varchar(128) NOT NULL default 'sdtrusfX0Jj66',
  `name` varchar(128) NOT NULL default '',
  `uid` smallint(5) unsigned NOT NULL default '5000',
  `gid` smallint(5) unsigned NOT NULL default '5000',
  `home` varchar(255) NOT NULL default '/var/spool/mail/virtual/',
  `maildir` varchar(255) NOT NULL default '',
  `quota` varchar(255) NOT NULL default '',
  `enabled` tinyint(3) unsigned NOT NULL default '1',
  `change_password` tinyint(3) unsigned NOT NULL default '1',
  `procmailrc` varchar(128) NOT NULL default '',
  `spamassassinrc` varchar(128) NOT NULL default '',
  `clear` varchar(128) NOT NULL default 'ChangeMe',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `id` (`id`)
) ;
