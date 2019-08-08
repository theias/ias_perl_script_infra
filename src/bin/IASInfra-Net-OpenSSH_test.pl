#!/usr/bin/perl

use strict;
use warnings;

use lib '/opt/IAS/lib/perl5';

use FindBin qw($RealBin);
use lib "$RealBin/../lib/perl5";

my $app = new IAS::Infra::Application::Net::OpenSSH::Test;

my $SVN_VERSION = q{$Id$};
$app->run($SVN_VERSION);

exit;

package IAS::Infra::Application::Net::OpenSSH::Test;

use base 'IAS::Infra';

use IAS::Infra::Net::OpenSSH;

use strict;
use warnings;
use File::Path qw(make_path);
use Getopt::Long;
use LWP::Simple;
use Data::Dumper;
use Net::OpenSSH;
use IO::File;
use JSON;
use Data::Dumper;

my $OPTIONS_VALUES = {};
BEGIN
{
	$OPTIONS_VALUES->{'credentials-file'} 
		= glob('~/.config/IAS/Infra-Net-OpenSSH-test.json');
	
}

sub main
{
	my ($self) = @_;
	
	my $ias_ssh = IAS::Infra::Net::OpenSSH->new({
		'credentials-file' => $OPTIONS_VALUES->{'credentials-file'},
		'ssh_options' => { host => 'localhost' },
	});
	
	# $ias_ssh->openssh_debug();
	
	my $ssh = $ias_ssh->get_ssh_session();
	
	my @ls = $ssh->capture("ls");
	$ssh->error and
		die "remote ls command failed: " . $ssh->error;

	print "IAS::Infra::Net::OpenSSH::OPTIONS_VALUES:\n";
	print Dumper($IAS::Infra::Net::OpenSSH::OPTIONS_VALUES),$/;
	print Dumper(\@ls);
}
