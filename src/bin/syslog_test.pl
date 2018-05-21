#!/usr/bin/perl

use strict;
use warnings;

=pod

=head1 NAME

syslog_test

=head1 DESCRIPTION

Should be expanded to test the routines in Logger::Syslog, or gotten
rid of

=cut

my $SVN_VERSION = q{$Id: syslog_test.pl 8123 2017-10-10 23:56:23Z mvanwinkle $};

use FindBin qw($RealBin);
use lib "$RealBin/../lib/perl5";
use lib "/opt/IAS/lib/perl5";

use Logger::Syslog;
use Cwd;

my $INSTANCE_ID = join("----",
	$0,
	'version:'.$SVN_VERSION,
	'cwd:'.getcwd(),
	'args:'.join(' ', @ARGV),
	'',
);

info($INSTANCE_ID . " --BEGINNING--");

info(" --ENDING--");
