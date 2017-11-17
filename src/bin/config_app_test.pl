#!/usr/bin/perl

use strict;
use warnings;

use lib '/opt/IAS/lib/perl5';

use FindBin qw($RealBin);
use lib "$RealBin/../lib/perl5";

my $app = new IAS::ConfigAppTest;

my $SVN_VERSION = q{$Id$};
$app->run($SVN_VERSION);

exit;

package IAS::ConfigAppTest;

use base 'IAS::Infra';


use strict;
use warnings;

use Data::Dumper;

=pod

=head1 NAME

Tests configuration module

=head1 SYNOPSIS

  config_app_test.pl

=head1 DESCRIPTION

Should manipulate "our $OPTIONS" under specific package names

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

sub setup
{
	my ($self) = @_;
	
	GetOptions(
		$OPTIONS,
		'config-option-one=s',
		'config-option-two=s',
		'config-option-three=s',
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
	
	$self->debug_paths();
	
	$self->log_debug('IAS::Infra::Logger Options before:');
	$self->logger_dump_options();
	
	my $config_attempt = {
		'IAS::Infra::Logger' => {
			# 'log-notice-stderr' => 1,
			'debug' => 1,
		},
	};
	
	$self->process_config(
		$config_attempt,
	);
	
	$self->log_debug('IAS::Infra::Logger Options after:');
	$self->logger_dump_options();

	
	$self->log_debug('IAS::ConfigAppTest Options:');
	$self->log_debug(Dumper($OPTIONS));

	print "----------------\nSelf\n-----------------\n";
	print Dumper($self);

}

sub main_1
{
	my ($self) = @_;
	
	my $new_options = {
		'b' => 'This was set in '.__PACKAGE__,
		'c' => 'This was set in '.__PACKAGE__,
	};

	no strict 'refs';
	my $target = 'IAS::Infra::Config::get_option_ref';
	my $ptr = \&{$target};
	
	my $remote_package_options = $ptr->();
	
	use strict 'refs';
		
	$self->log_debug(
		"New options:\n",
		Dumper($new_options),
	);
	
	$self->log_debug(
		"Remote Package options before: \n",
		Dumper($$remote_package_options),
	);

	use Hash::Merge::Simple;
	
	my $replacement = Hash::Merge::Simple::merge(
		$$remote_package_options,
		$new_options,
	);
	
	$$remote_package_options=$replacement;

	$self->log_debug(
		"Remote Package options after: \n",
		Dumper($replacement),
	);

	
	$remote_package_options = $ptr->();
	
	$self->log_debug(
		"Remote Package options re-fetch: \n",
		Dumper($$remote_package_options),
	);
}


1;

