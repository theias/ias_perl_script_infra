#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($RealBin);
use lib "$RealBin/../lib/perl5";

use lib '/opt/IAS/lib/perl5';

my $app = new IAS::TimeTravelTest;

my $SVN_VERSION = q{$Id$};
$app->run($SVN_VERSION);

exit;

package IAS::TimeTravelTest;

use base 'IAS::Infra';


use strict;
use warnings;

use Data::Dumper;

=pod

=head1 NAME

Tests TimeTravel

=head1 SYNOPSIS

  time_travel_test.pl

=head1 DESCRIPTION

Run with --start-date and --end-date

=head1 DOCUMENTATION

=over

=item Wiki page:

=item RT Ticket Number:

=back

=head1 AUTHOR

In general, anybody.  Currently: Martin VanWinkle

=cut

use Pod::Usage;
use Getopt::Long;

our $OPTIONS;
BEGIN{
	# print "Init!\n";
	$OPTIONS={};
}

sub main
{
	my ($self) = @_;
	
	use Data::Dumper;
	
	my $start_date = $self->get_start_date();
	my $end_date = $self->get_end_date();
	
	my $start_result;
	my $end_result;
	
	if (defined $start_date)
	{
		$start_result = $start_date->printf('%s');
	}
	
	if (defined $end_date)
	{
		$end_result = $end_date->printf('%s');
	}
	
	print "Start date:",$/;
	print Dumper($start_result);
	
	print "End date:",$/;
	print Dumper($end_result);

}

1;

