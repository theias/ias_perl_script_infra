#!/usr/bin/perl

package IAS::Infra::NoRun;

=pod

=head1 NAME

IAS::Infra::NoRun

=head1 SYNOPSIS

This module searches through a list of configuration directories ($self->get_all_config_dirs())
for files named NORUN, or for files named (where if the current script is
script_name.pl) script_name-NORUN

Scripts call $self->should_i_run() to determine if they should run.

=head1 OPTIONS

=over 4

=item * --dont-run - should_i_run() always returns 0

=item * --ignore-norun - should_i_run() will return 1 unless --dont-run is specified.

=item * --norun-filename - If you decide to call your NORUN file something different, say 'DONT-RUN' ,
the module will look for DONT-RUN and script_name-DONT-RUN.

=item * --debug-norun - Verbose debugging for this module via log_debug();

=back

=cut

use strict;
use warnings;

use Getopt::Long;

our $DEFAULT_OPTIONS={
	'norun-filename' => 'NORUN',
};

our $OPTIONS={};

{
	local $Getopt::Long::passthrough=1;

	GetOptions(
		$OPTIONS,
		'dont-run',
		'ignore-norun',
		'norun-filename=s',
		'debug-norun',
	);

}

sub debug_norun
{
	my ($self, @msg) = @_;
	
	if (! $OPTIONS->{'debug-norun'})
	{
		return;
	}
	
	$self->log_debug('NORUN: ', @msg);
}

sub apply_options_precedence
{
	use Hash::Merge::Simple;
	
	my ($config_options) = @_;

	$DEFAULT_OPTIONS = Hash::Merge::Simple::merge(
		$DEFAULT_OPTIONS,
		$config_options
	);
	
	$OPTIONS = Hash::Merge::Simple::merge(
		$DEFAULT_OPTIONS,
		$OPTIONS,
	);
	
	
}

our $REASON;

sub should_i_run
{
	my ($self) = @_;
	
	if ($OPTIONS->{'dont-run'})
	{
		$REASON = "--dont-run specified as an argument";

		$self->debug_norun($REASON);
		
		return 0;
	}
	
	if ($OPTIONS->{'ignore-norun'})
	{
		$REASON = '--ignore-norun specified as an argument.';
		$self->debug_norun($REASON);
		return 1;
	}
		
	my $config_dirs = $self->get_all_config_dirs();
	
	foreach my $config_dir (@$config_dirs)	
	{
		my $project_norun_file_name = join('/',$config_dir,$OPTIONS->{'norun-filename'});

		$self->debug_norun("Checking for: $project_norun_file_name");
		
		if (-e $project_norun_file_name)
		{
			$REASON = "$project_norun_file_name exits.";
			$self->debug_norun($REASON);
			return 0;	
		}
		
		my $script_norun_file_name = join('/',
			$config_dir,
			$self->script_without_extension().'-'.$OPTIONS->{'norun-filename'}
		);
		
		$self->debug_norun("Checking for: $script_norun_file_name");
		
		if (-e $script_norun_file_name)
		{
			$REASON = "$script_norun_file_name exists.";
			$self->debug_norun($REASON);
			return 0;
		}
	}
	
	return 1;
}

sub get_norun_reason
{
	my ($self) = @_;
	return $REASON;
}

1;
