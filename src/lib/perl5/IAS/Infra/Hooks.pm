#!/usr/bin/perl

use strict;
use warnings;

package IAS::Infra::Hooks;

=pod

=head1 NAME

IAS::Infra::Hooks

=head1 DESCRIPTION

Calls the hooks you specify in your script.

Similar to / inspired by hooks specified in CGI::Application

It should be noted that as I document more I remember more.
None should be taken as gospel.

Sometimes it's excessive to anticipate the needs of a programmer.
And, it's foolish.  However, some things follow a common structure.
Not everything will be used, some will be different.

The idea isn't that definitions and call backs for these stages
need to be implemented, it's that patterns should be recognized.

Things can happen in the following order:
  Log program start
  Setup
  	Process command line options
  	Read configuration directives
  	Perform any overrides that command line options do over configuration directives
  Initialize  	
  	Initialize database connections (etc)
  Do work
  Tear Down
   	Close database connections (etc
  Log program end

=head1 HOOKS

=over

=item * setup -- this is where you could call any routines
that process command line options.

=item * init

=item * run -- where the "main" work of your program lives.

=item * tear_down

=back

=cut

sub run
{
	my (
		$self,
		$SVN_VERSION,
	) = @_;
	
	$self->log_start_log($SVN_VERSION);

	$self->load_config();	
	IAS::Infra::NoRun::apply_options_precedence({});

	if (! $self->should_i_run())
	{
		$self->log_info('I should not run.  Reason: '.$self->get_norun_reason());
		
	}

	else
	{
		IAS::Infra::Logger::apply_options_precedence({});
		IAS::Infra::Hooks::apply_options_precedence({});
		IAS::Infra::FullProjectPaths::apply_options_precedence({});
		IAS::Infra::Config::apply_options_precedence({});
	
		$self->setup()
			if ($self->can('setup'));
	
		$self->init()
			if ($self->can('init'));
	
		$self->main();

		my $end_time = time;

		$self->tear_down()
			if ($self->can('tear_down'));
	}
	$self->write_exit_log();
	
}



sub apply_options_precedence
{

}

1;
