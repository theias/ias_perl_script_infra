#!/usr/bin/perl

use strict;
use warnings;

### CGI-Bin Infrastructure

###################################
# This hopefully is both cgi script compatible
# and mod_perl compatible
use Cwd;
use File::Basename;
my $RealPath;
BEGIN {
	
	$RealPath = Cwd::realpath(__FILE__);
}
use lib dirname($RealPath).'/../lib/perl5';
use lib '/opt/IAS/lib/perl5';

my $app = new IAS::CGIBin::Application1;

$app->run();

exit;


### End CGI-Bin Infrastructure

package IAS::CGIBin::Application1;

use IAS::Infra::CGIBinPaths;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub new
{
	my ($type, $self) = shift;

	return bless $self, $type;
}

sub run
{
	my ($self) = @_;
	
	my $cgi = CGI->new();
	
	print $cgi->header();
	
	print "Hello.\n";
}

exit;



1;
