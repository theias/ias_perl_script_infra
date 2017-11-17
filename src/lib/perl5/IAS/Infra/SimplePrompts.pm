package IAS::Infra::SimplePrompts;

=pod

=head1 NAME

IAS::Infra::SimplePrompts

=head1 SYNOPSIS

  my $user_name = $self->simple_stdin_prompt("Username: ");  
  my $password = $self->simple_stdin_password_prompt("Password:");

=head1 DESCRIPTION

Simple prompts for getting things like user name and password from stdin.

=cut

use strict;
use warnings;

use Term::ReadKey;

sub simple_stdin_prompt
{
	my ($self, $prompt) = @_;
	if (defined $prompt)
	{
		print $prompt;
	}
	
	my $line = <STDIN>;
	
	chomp($line);
	return $line;
}

sub simple_stdin_password_prompt
{
	my ($self, $prompt) = @_;
	
	use Term::ReadKey;

	if (defined $prompt)
	{
		print $prompt;
	}

	ReadMode('noecho');
	my $password = ReadLine(0);
	
	ReadMode('restore');
	print "\n";
		chomp($password);
	return $password;
}

1;
