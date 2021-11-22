#!/usr/bin/perl

use strict;
use warnings;

package IAS::Infra;

our @ARGV_COPY;
my $ASSUMED_USER;

BEGIN{
	@ARGV_COPY = @ARGV;
	my @getpwuid_results = getpwuid($<);
	
	$ASSUMED_USER =
		$ENV{USER}
		|| $getpwuid_results[0];

};

=pod

=head1 NAME

IAS::Infra

=head1 SYNOPSIS

  # Please see AnIASApplication
  # Short synopsis:
  my $app = new AnIASApplication;

  my $SVN_VERSION = q{$Id$};
  $app->run($SVN_VERSION);

  exit;

  package AnIASApplication;
  use base 'IAS::Infra';

  sub run
  {
    my ($self) = @_;
    $self->log_info("Hello, world!");
  }
    

=head1 DESCRIPTION

IAS::Infra contains a collection of modules each focusing on different aspects of
infrastructure design.  For more information on the individual modules, please perldoc
the modules mentioned in the MODULES section below.

=head2 MODULES

=over

=item * IAS::Infra::Logger - Output routines for logging, and debugging.
Please consider using this before you print anything to stdout or stderr.
(unless your program is designed to be used in a set of pipes, or otherwise)

=item * IAS::Infra::Hooks - Calls hooks specified in your script.

=item * IAS::Infra::FullProjectPaths - Makes your script self aware of its location.
Also provides the majority (if not ALL) of the paths to everything, and provides
means to override all paths via command line options.

=item * IAS::Infra::TimeTravel - Date / Time specification from the command line

=item * IAS::Infra::Config - Loads configuraton files, and applies merges to the
specified modules' $OPTIONS={} data structure.

=item * IAS::Infra::SimplePrompts - Simple prompts for user input, passwords

=back

=head1 STANDARDS ADHERENCE

These modules were designed to help adhere to the following standards:

=over

=item * Proper syslog log levels

=item * No output when run from cron

=back

=cut

use base 'IAS::Infra::Logger';
use base 'IAS::Infra::Hooks';
use base 'IAS::Infra::FullProjectPaths';
use base 'IAS::Infra::TimeTravel';
use base 'IAS::Infra::Config';
use base 'IAS::Infra::SimplePrompts';
use base 'IAS::Infra::NoRun';

sub new
{
	my $type = shift;
	my $self = {};
	return bless $self, $type;
}

sub get_assumed_user
{
	my ($self) = @_;
	
	return $ASSUMED_USER;
}


1;
