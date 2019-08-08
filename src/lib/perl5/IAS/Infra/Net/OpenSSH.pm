package IAS::Infra::Net::OpenSSH;

=pod

=head1 NAME

IAS::Infra::Net::OpenSSH

=head1 SYNOPSIS

  my $ias_ssh = IAS::Infra::Net::OpenSSH->new({
  	'credentials-file' => '~/.config/IAS/artifact-name/credentials.json',
  	'ssh_options' => { host => 'localhost' },
  });

  # Show what automagic things are going to happen
  # NOTE: This might dump sensitive information to the terminal!
  # $ias_ssh->openssh_debug();

  my $ssh = $ias_ssh->get_ssh_session();

  my @ls = $ssh->capture("ls");
  $ssh->error and
  	die "remote ls command failed: " . $ssh->error;

  print Dumper(\@ls);

=head1 DESCRIPTION

This module tries to automatically figure out what parameters should be passed
to Net::OpenSSH, so that things such as the underlying authentication method
(password, or keys) do not need to be accounted for when using Net::OpenSSH.

=head2 Fields

=over 4

=item * user - It gets this from either the "user" field passed to it, or from
the "username" field in the credentials file.  If no user is specified,
and the module is configured to prompt for credentials, it will prompt for the
user.  Otherwise, it returns undefined.

=item * key_path - This is called "key_path" in both the constructor, and
the credentials file.  This is (currently) not prompted for.

=item * password - If no key_path is specified, and no password is specified,
it will prompt for a password if it is configured to prompt.

=back

=head1 Credentials File

Because LastPass stores the user name in the "username" field, and this
is designed to integrate with LastPass (eventually), favor was given to
use "username" instead of "user" to store the username.

=head2 Credentials File Format

The format is JSON.

  {
  	"username":"user",
  	"key_path":"~/.ssh/id_rsa"
  }

Or

  {
  	"username":"user",
  	"password":"SomeSecretPassword"
  }

=head3 Examples of Optional Values

  "prompt-for-credentials" : 0,
  "raise-error": 1

=head1 Configuration, and Command Line Options

This is complicated and I need to figure out how to document this better.

Basically, this was written with a sort of "minimal" coding requirement,
where if you were only going to have 1 SSH connection, you need not implement
certain things in your program as command line arguments.  I'll use "one-shot"
and "not one-shot" to differentiate things.

Both types of options (one-shot and non-one-shot) are supported as arguments,
and as parameters to the new constructor.

Please see @OPTIONS for a list of all options that are supported.

The defaults are in $OPTIONS_VALUES .

In this list of options, the command line option is named first, and the
constructor option is in parenthesis.

=head2 Non One-Shot Options

=over 4

=item * openssh-prompt-for-credentials (prompt-for-credentials) - if anything
seems to be missing (user name, password (if key_path not specified) ) then
prompt for them.  This can be specified as "prompt-for-credentials" inside
of the credentials file.

=item * openssh-raise-error (raise-error) - if the module thinks that an error
is serious enough, then let it decide whether to exit (as opposed to just
returning undef).

=back

Used in conjuction with each other, the following option combinations should
be suitable for an automation environment (provided they weren't somehow
overridden by code that's not doing the right thing):

=over 4

=item * openssh-prompt-for-credentials=0

=item * openssh-raise-error=1

=back

=head2 One-Shot Options

If you intend to only connect to one SSH server, and you want this to
figure everything out for you, then these are the options that do it.

(I don't recommend using these as command line arguments).

=over 4

=item * openssh-key_path (key_path) - Location of the key to use when logging
in (e.g. ~/.ssh/id_rsa)

=item * openssh-credentials-file (credentials-file) - location of credentials
file

=item * openssh-user (user) - user to connect as

=item * openssh-password (please don't hard code this... This module was
designed to help you not need to do this) - Yes, it's a bad idea to use this as
a command line argument as well.	

=back

=head1 Notes

=head2 Don't Rely on the Default key_path

OpenSSH will, by default, try to use ~/.ssh/id_rsa as a key_path.  If the
key is valid, and allows for you to log in, this will allow you to only
specify the "username" field in the credentials file, and still make a
connection.  But, the module will "warn" about this.  As this modules intended
use is to have a common interface to a variety of credential files, I
recommend that if you intend on using keys for authentication that you
explicity state the key_path (either in the credentials file, or in code).

=cut

use strict;
use warnings;

use Net::OpenSSH;
use Data::Dumper;
use JSON;
use Getopt::Long;
use File::Slurp;
use Carp;

use base 'IAS::Infra::SimplePrompts';

our @OPTIONS = (
	'openssh-prompt-for-credentials!',
	'openssh-raise-error!',
	'openssh-dump-self!',
	'openssh-credentials-file=s',

	'openssh-key_path=s',
	'openssh-user=s',
	'openssh-password=s',
	
);

our $OPTIONS_VALUES = {

};

sub apply_options_precedence
{
	use Hash::Merge::Simple;
	
	my ($config_options) = @_;

	$OPTIONS_VALUES = Hash::Merge::Simple::merge(
		$OPTIONS_VALUES,
		$config_options
	);
	
}

{
	local $Getopt::Long::passthrough=1;

	GetOptions(
		$OPTIONS_VALUES,
		@OPTIONS,
	);

}


sub build_ssh_options
{
	my ($self) = @_;

	if (defined $self->{'credentials-file'})
	{
		$self->load_ssh_credentials_file();
	}
	my $cd = $self->{'credentials-data'};
	
	$self->{'prompt-for-credentials'} //= $cd->{'prompt-for-credentials'};
	$self->{'raise-error'} //= $cd->{'raise-error'};

	my $ssh_options = {};
	
	$ssh_options->{user} =
		$self->{'user'}
		// $cd->{'username'}
		// $self->get_username_prompt();

	$ssh_options->{'key_path'} =
		$self->{'key_path'}
		// $cd->{'key_path'};
	delete $ssh_options->{'key_path'}
		if (! defined $ssh_options->{'key_path'});
	
	if (defined $ssh_options->{'key_path'})
	{
		$ssh_options->{'key_path'} = glob($ssh_options->{'key_path'});
	}
	
	$ssh_options->{password} = 
		$self->{password}
		// $cd->{password};
	
	# If we don't have a key path, or a password
	# prompt for a password
	if (! defined $ssh_options->{'key_path'}
		&& ! defined $ssh_options->{'password'}
	)
	{
		$ssh_options->{password} //= $self->get_password_prompt();
	}
	
	delete $ssh_options->{password}
		if (! defined $ssh_options->{password});
	
	$self->{built_ssh_options} = $ssh_options;

}

sub set_err_msg
{
	my ($self, $msg) = @_;
	
	$self->{err_msg} = $msg;

	if ($self->{'raise-error'})
	{
		if ($OPTIONS_VALUES->{'openssh-dump-self'})
		{
			print STDERR "openssh-dump-self is set.  Dumping.\n";
			print STDERR Dumper($self),$/;
		}
		confess $msg,$/;
	}
}

sub err_msg
{
	my ($self) = @_;
	
	return $self->{err_msg};	
}

sub get_username_prompt
{
	my ($self) = @_;
	
	if (! $self->{'prompt-for-credentials'} )
	{
		$self->set_err_msg("I don't have a username, and I was configured to not prompt.");
		return undef;
	}
	return $self->simple_stdin_prompt("SSH username: ");
}

sub get_password_prompt
{
	my ($self) = @_;
	
	if (! $self->{'prompt-for-credentials'} )
	{
		$self->set_err_msg("I don't have a password, and I was configured to not prompt.");
		return undef;
	}
	return $self->simple_stdin_password_prompt("SSH password: ");
}


sub new
{
	my ($type, $hr) = @_;
	my $self = $hr;
	$self ||= {};
	
	$self->{'raise-error'} //=
		$OPTIONS_VALUES->{'openssh-raise-error'};
	
	$self->{'prompt-for-credentials'}
		//= $OPTIONS_VALUES->{'openssh-prompt-for-credentials'};
	
	$self->{'credentials-file'} //= $OPTIONS_VALUES->{'openssh-credentials-file'};
	$self->{'key_path'} //= $OPTIONS_VALUES->{'openssh-key_path'};
	$self->{'user'} //= $OPTIONS_VALUES->{'openssh-user'};
	
	bless $self, $type;
	
	$self->build_ssh_options();
	
	return $self;
}

sub get_ssh_session
{
	my ($self) = @_;

	# print Dumper($self->{built_ssh_options}),$/;
	# print Dumper($self->{ssh_options}),$/;
	# exit;

	my $ssh = Net::OpenSSH->new(
		%{$self->{built_ssh_options}},
		%{$self->{'ssh_options'}},
	);



	$self->{ssh_session} = $ssh;
	
	return $ssh;
}

sub load_ssh_credentials_file
{
	my ($self) = @_;
	
	my $file_name = glob($self->{'credentials-file'});
	my $json = JSON->new->allow_nonref();
	my $contents = read_file($file_name);
	$self->{'credentials-data'} = $json->decode($contents);
	
}


sub openssh_debug
{
	my ($self) = @_;
	
	print __PACKAGE__," openssh_debug\n";
	
	print "Self:\n";
	print Dumper($self),$/;
	
	print "OPTIONS_VALUES\n";
	print Dumper($OPTIONS_VALUES),$/;
	
}
1;
