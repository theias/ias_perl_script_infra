package IAS::Infra::TimeTravel;

=pod

=head1 NAME

IAS::Infra::TimeTravel

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Processes the command line options --start-date and --end-date

Uses Date::Manip to get meaning from those options.

See time_travel_test.pl for more (potentially).

=cut


use strict;
use warnings;

use Carp;

# libdate-manip-perl
use Date::Manip;
use Getopt::Long;


our $OPTIONS={};

{

	local $Getopt::Long::passthrough=1;

	GetOptions(
		$OPTIONS,
		'start-date=s',
		'end-date=s',
	);

}

sub apply_options_precedence
{
	use Hash::Merge::Simple;
	
	my ($config_options) = @_;
	
	$OPTIONS = Hash::Merge::Simple::merge(
		$config_options,
		$OPTIONS,
	);
}

sub fetch_date_wrapper
{
	my ($self, $field) = @_;
	
	return undef
		if (! $OPTIONS->{$field});
	
	my $err;
	my $date = new Date::Manip::Date;
	
	$err = $date->parse($OPTIONS->{$field});
	
	if ($err)
	{
		croak "Bad date: ".$OPTIONS->{$field}
			."\n"
			.$date->err();
	}
	
	return $date;
}


sub get_start_date
{
	my ($self) = @_;
	
	return $self->fetch_date_wrapper('start-date');
	
}
sub get_end_date
{
	my ($self) = @_;
	
	return $self->fetch_date_wrapper('end-date');
	
}

1;
