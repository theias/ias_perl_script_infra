#!/usr/bin/perl

use strict;
use warnings;

use lib '/opt/IAS/lib/perl5';

use FindBin qw($RealBin);
use lib "$RealBin/../lib/perl5";

my $app = new AnIASApplication;

my $SVN_VERSION = q{$Id: an_ias_application.pl 8123 2017-10-10 23:56:23Z mvanwinkle $};
$app->run($SVN_VERSION);

exit;

package AnIASApplication;
use base 'IAS::Infra';

=pod

=head1 NAME

A simple IAS Application

=head1 SYNOPSIS

  an_ias_application.pl \
  [ --times ] # Number of times to greet people; defaults to 1
  --name marty [ --name brian ] ...

It is an IAS::Infra application.  Please see perldoc IAS::Infra for more
information

=head1 DESCRIPTION

This script will say hello to anybody you name with --name

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

our %OPTIONS;

sub setup
{
	my ($self) = @_;
	
	GetOptions(
		\%OPTIONS,
		'name=s@',
		'times=i',
	);
	
	$OPTIONS{times}||=1;
	
	
	use Data::Dumper;
	if (
		!$OPTIONS{name}
		|| ! scalar (@{$OPTIONS{name}})
	)
	{
		my $message = 'You must give me at least one name as an argument with --name';
		$self->log_critic($message);
		pod2usage ( -message => $message, -exitval => 1);
		exit 1;
	}
}

sub main
{
	my ($self) = @_;
	
	$self->log_debug(
		"This is a debug message.  ",
		"It doesn't show up anywhere unless --debug is specified on the command line."
	);
	
	$self->log_debug(
		"Debug messages will be printed to stdout ",
		"if you specify --log-debug-stdout"
	);
	
	$self->say_hello();
}

sub say_hello
{
	my ($self) = @_;
	
	return if (! $OPTIONS{name});
	
	
	my @names=@{$OPTIONS{name}};
	
	my $name;
	foreach $name (@names)
	{
		$self->log_info("Saying hello to $name");
		$self->log_debug("Number of times: ".$OPTIONS{'times'});
		for (1..$OPTIONS{'times'})
		{
			$self->log_debug_named(['say_hello'], 'Say hello. Inner loop');
			$self->log_debug("Hello to $name");
			$self->log_debug("So nice to see you!");
		}
		$self->log_info("Said hello to $name");
	}
}

1;
