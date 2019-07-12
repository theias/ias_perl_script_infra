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

use CGI;
# use CGI::Carp qw(fatalsToBrowser);

use Data::Dumper;

use IAS::Infra::CGIBinPaths;

sub new
{
	my ($type, $self) = shift;

	$self->{CBP} = IAS::Infra::CGIBinPaths->new();
	return bless $self, $type;
}

sub run
{
	my ($self) = @_;
	
	my $cgi = CGI->new();
	
	print $cgi->header();
	
	print "Hello.\n";
	print Dumper($self->{CBP}),$/;
}

exit;



1;
