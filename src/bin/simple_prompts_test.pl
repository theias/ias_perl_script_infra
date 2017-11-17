#!/usr/bin/perl

use strict;
use warnings;

use lib '/opt/IAS/lib/perl5';

use FindBin qw($RealBin);
use lib "$RealBin/../lib/perl5";

my $app = new IAS::SimplePromptsTest;

my $SVN_VERSION = q{$Id$};
$app->run($SVN_VERSION);

exit;

package IAS::SimplePromptsTest;

use base 'IAS::Infra';


use strict;
use warnings;

use Data::Dumper;

=pod

=head1 NAME

Tests Prompt Module

=head1 SYNOPSIS

  simple_prompts_test.pl

=head1 DESCRIPTION

Accepts username and password input.

Should not reveal password input.

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
	
	my $user_name = $self->simple_stdin_prompt("User: ");
	my $password = $self->simple_stdin_password_prompt("Password: ");
	
	$password =~ s/./\*/g;
	
	print "Username: $user_name\n";
	print "Redacted password: $password\n";
}

1;

