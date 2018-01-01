#!/usr/bin/perl

package IAS::Infra::NoRun;

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
