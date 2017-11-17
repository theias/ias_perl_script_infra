#!/usr/bin/perl

use strict;
use warnings;

use lib '/opt/IAS/lib/perl5';

use FindBin qw($RealBin);
use lib "$RealBin/../lib/perl5";

my $app = new IAS::NewApp1;

my $SVN_VERSION = q{$Id$};
$app->run($SVN_VERSION);

exit;

package IAS::NewApp1;

use base 'IAS::Infra';


use strict;
use warnings;

use Data::Dumper;

=pod

=head1 NAME

NewApp1

=head1 SYNOPSIS

  new_app_1.pl --name brian --name marty

=head1 DESCRIPTION

Says hello to whomever

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
	$OPTIONS={};
}

sub setup
{
	my ($self) = @_;
	
	GetOptions(
		$OPTIONS,
		'name=s@',
		'greeting=s',
		'times=i',
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


sub main
{
	my ($self) = @_;
	
	# $self->log_debug(Dumper($OPTIONS));

	if (
		!$OPTIONS->{name}
		|| ! scalar (@{$OPTIONS->{name}})
	)
	{
		my $message = 'You must give me at least one name as an argument with --name';
		$self->log_critic($message);
		pod2usage ( -message => $message, -exitval => 1);
		exit 1;
	}

	$OPTIONS->{'greeting'} ||= 'Hello, ';
	
	$self->say_hello();	

}

sub say_hello
{
	my ($self) = @_;
	
	my @names = @{$OPTIONS->{name}};
	
	my $name;
	
	foreach $name (@names)
	{
		$self->log_info($OPTIONS->{'greeting'} . " $name!");
	}	
}
1;

