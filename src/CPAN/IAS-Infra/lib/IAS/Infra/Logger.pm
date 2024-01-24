package IAS::Infra::Logger;

=pod

=head1 NAME

IAS::Infra::Logger

=head1 SYNOPSIS

  # Loging options (all optional)

  # Most useful for debugging, turns on lots of options
  --log-devel

  # Enable debugging output in the logs	
  --log-debug
  
  # Copy "error" messages to stderr
  --log-stderr # Defaults to on

  # Copy all log messages to stdout (useful for debugging)
  --log-stdout
  
  # Copy log notices to std{whatever}
  --log-notice-stderr!',
  --log-notice-stdout!',	

  # Copy debugging log output to stdout
  --log-debug-stdout

  
  # Specify named debug labels
  --log-debug-names=name1 [ --log-debug-names=name2... ]


=head1 DESCRIPTION

Assumes the primary logging method will be syslog.

=cut


use strict;
use warnings;

use Carp qw(cluck carp croak);
use Getopt::Long;
use Data::Dumper;
use Logger::Syslog();

our %DEBUG_NAMES_HASH;
our $OPTIONS={
	'log-cluck-bad-message' => 1,
};

my $LOG_START_TIME = time;



{
	local $Getopt::Long::passthrough=1;


GetOptions(
	$OPTIONS,
	'log-stderr!',
	'log-stdout!',
	
	'log-notice-stderr!',
	'log-notice-stdout!',	
	
	'log-debug!',
	'log-debug-stdout!',
	'log-devel!',
	
	'log-debug-names=s@',
	'log-cluck-bad-message!',
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
	
	if (! defined $OPTIONS->{'log-stderr'} )
	{
		$OPTIONS->{'log-stderr'} = 1;
	}
	
}

sub logger_dump_options
{
	my ($self) = @_;
	
	$self->log_debug(Dumper($OPTIONS));
}

if (defined $OPTIONS->{'log-debug-names'})
{
	@DEBUG_NAMES_HASH{@{$OPTIONS->{'log-debug-names'}}}
		= (1) x scalar(@{$OPTIONS->{'log-debug-names'}});
}

sub log_cluck_bad_message
{
	my ($self, @msg) = @_;

	if ($OPTIONS->{'log-cluck-bad-message'})
	{


		if (scalar grep { ! defined $_ } @msg )
		{
			cluck "Element of msg was undefined.";
		}

		if (! scalar @msg)
		{
			cluck "No message was passed.";
		}
	}
}

sub log_debug_named
{
	my ($self, $names_ar, @msg) = @_;
	
	my @causes;
	
	push @causes, 'ALL' if ($DEBUG_NAMES_HASH{'ALL'});
	
	foreach my $element (@$names_ar)
	{
		if ($DEBUG_NAMES_HASH{$element})
		{
			push @causes, $element;
		}
	}
	
	if (scalar(@causes))
	{
		
		$self->log_debug(join(',',@causes),'||',@msg);
	}
}

sub get_log_message
{
	my ($self, @msg) = @_;
	
	my $msg_format = join(' ',
		scalar(gmtime),
		$0,
		$$,
		@msg
	).$/;
	
	return $msg_format;
}

sub log_debug
{
	my $self = shift;
	my (@msg) = @_;

	$self->log_cluck_bad_message(@msg);

	print $self->get_log_message('DEBUG',@msg)
		if (
			$OPTIONS->{'log-debug-stdout'}
			|| $OPTIONS->{'log-devel'}
		);
	
	my $msg = join(" ", @msg);	
	
	Logger::Syslog::debug($msg)
		if (
			$OPTIONS->{'log-debug'}
			|| $OPTIONS->{'log-devel'}
		);
}

sub log_info
{
	my $self = shift;
	my (@msg) = @_;

	$self->log_cluck_bad_message(@msg);

	if ($OPTIONS->{'log-stdout'} || $OPTIONS->{'log-devel'})
	{
		print $self->get_log_message('INFO', @msg);
	}


	my $msg = join(" ", @msg);

	Logger::Syslog::info($msg);
}

sub log_warning
{
	my $self = shift;
	my (@msg) = @_;
	
	$self->log_cluck_bad_message(@msg);

	print STDERR get_log_message('WARNING', @msg)
		if (
			$OPTIONS->{'log-stderr'}
			|| $OPTIONS->{'log-devel'}
		);
	my $msg = join(" ", @msg);
	Logger::Syslog::warning($msg);	
}

sub log_error
{
	my $self = shift;
	my (@msg) = @_;

	$self->log_cluck_bad_message(@msg);
	
	print STDERR get_log_message('ERROR', @msg)
		if (
			$OPTIONS->{'log-stderr'}
			|| $OPTIONS->{'log-devel'}
		);
	my $msg = join(" ", @msg);
	Logger::Syslog::error($msg);	
}

sub log_notice
{
	my $self = shift;
	my (@msg) = @_;
	
	$self->log_cluck_bad_message(@msg);

	print STDERR get_log_message('NOTICE', @msg)
		if (
			$OPTIONS->{'log-stderr'}
			|| $OPTIONS->{'log-devel'}
		);
	my $msg = join(" ", @msg);
	Logger::Syslog::notice($msg);	
}

sub log_die
{
	my ($self, $exit_code, @msg) = @_;

	$self->log_cluck_bad_message(@msg);
	
	$self->log_critic(@msg);
	
	$self->write_exit_log();
	exit $exit_code;	
	
}

sub write_exit_log
{
	my ($self) = @_;

	my $end_time = time;
	my $run_time_seconds = $end_time - $LOG_START_TIME;
	$self->log_end_log("run time: $run_time_seconds seconds");
	
}

sub log_critic
{
	my $self = shift;
	my (@msg) = @_;
	
	$self->log_cluck_bad_message(@msg);

	print STDERR get_log_message('CRITICAL', @msg)
		if (
			$OPTIONS->{'log-stderr'}
			|| $OPTIONS->{'log-devel'}
		);
	my $msg = join(" ", @msg);
	Logger::Syslog::critic($msg);	
}

sub log_alert
{
	my $self = shift;
	my (@msg) = @_;
	
	$self->log_cluck_bad_message(@msg);

	print STDERR get_log_message('ALERT', @msg)
		if (
			$OPTIONS->{'log-stderr'}
			|| $OPTIONS->{'log-devel'}
		);
	my $msg = join(" ", @msg);
	Logger::Syslog::alert($msg);	
}

sub log_end_log
{
	my ($self, @msg) = @_;
	
	$self->log_cluck_bad_message(@msg);

	my $msg = join(" ", @msg, '--ENDING--');
	$self->log_info($msg);
}

sub log_start_log
{

	use Cwd;

	Logger::Syslog::logger_init();

	my (
		$self,
		$SVN_VERSION,
	) = @_;

	use JSON;
	my $json_argv = encode_json(\@IAS::Infra::ARGV_COPY);

	my $INSTANCE_ID = join("----",
		'user:'.$self->get_assumed_user(),
		$0,
		'version:'.$SVN_VERSION,
		'cwd:'.getcwd(),
		'args:'.join(' ', $json_argv),
		'',
	);

	$self->log_info($INSTANCE_ID . " --BEGINNING--");
}


1;
