#!/usr/bin/perl

package IAS::Infra::FullProjectPaths;

use FindBin qw($Bin $RealBin $Script $RealScript);
use File::Basename;
use File::Spec;
use Getopt::Long;
use Data::Dumper;

use strict;
use warnings;

our $DEFAULT_OPTIONS={};

our $OPTIONS={};

=pod

=head1 NAME

IAS::Infra::FullProjectPaths

=head1 SYNOPSIS

  use base 'IAS::Infra::FullProjectPaths';
  ...
  $self->debug_paths();


=head1 DESCRIPTION

This path module provides is some ways of sensibly figuring out
where files should go based off of whether or not you're in a source tree or not.

A typical source tree might look like this:

  project_name/src/bin/script_name.pl

A split on the directories would look like this:
  ( "project_name" , "src", "bin" )

If the path at [-2] in the array is "src", we guess that we're in a source tree
and look set our paths accordingly.

Provided that decision isn't overrided by either configuration or command line
options we can begin to figure out where files should go or be found; sometimes
relative to the script, sometimes specified by a full path.

=head2 Features and Usage

=over 4

=item * Output Files

=item * Input Files

=item * Configuration Files

=item * TODO: Log Files

=item * TODO: NORUN

=item * TODO: HTTP URLs

=back

=head3 Output Files

  [ --output-dir ]

In dev mode we probably want output files to go here:

  project_name/src/output/

Which, relative to the script would be:

  ../output/

where "output/" is checked in to the repo, but everything under it is ignored.

This allows you to check out your project and just get working.

Outside of a source tree, we'd probably deploy to something like this:

  /opt/IAS/bin/package-name/script.pl

And we'd want our output directory to be:

  /opt/IAS/output/package-name/

Which we want our script to output things to (relative):
  ../../output/package-name/

=head3 Input Files

  [ --input-dir ]

In src, sets input file path to:

  ../input/

"installed", sets input file path to:

  ../../input/package-name

=head3 Configuration Files

The options here are many, and it's purposful.

This module only provides "sensible default" paths to these files.

The files are loaded and processed in another module: IAS::Infra::Config.pm

You have the ability in your source tree to provide an src/etc/ directory which
will eventually live in /opt/IAS/etc/project-name , and a src/root_etc/ directory
which will eventually live in /etc/IAS/project-name/

You also can have a ~/.config/IAS directory .

Under all of those directories there can be the following files:

=over 4

=item * script_name.json [ --json-script-config-name ]

=item * project-name.json [ --json-project-config-name ]

=back

So, in total, the script is aware of the following sets of paths for configuration files:

=head4 Project based script / configuration files:

These files are what would AND OR do live under

  /opt/IAS/etc/project-name/  [ --conf-dir ]

=over 4

=item * ../etc/project-name.json (dev)

=item * ../etc/script_name.json (dev)

=back

Which will be installed to:

=over 4

=item * ../../etc/project-name/script_name.json ("installed")

=item * ../../etc/project-name/project-name.json ("installed")

=back

=head4 "Global" configuration files:

These files are what would AND OR do live under

  /etc/IAS/project-name/  [ --root-conf-dir ]

=over 4

=item * ../root_etc/IAS/project-name/script_name.json (dev)

=item * ../root_etc/IAS/project-name/project-name.json (dev)

=back

Which will be installed to:

=over 4

=item * /etc/IAS/project-name/script_name.json ("installed")

=item * /etc/IAS/project-name/project-name.json ("installed")

=back 

=head4 User Configuration Files

Located under

  ~/.config/IAS/project-name/ [ --home-conf-dir ]

=over 4

=item * ~/.config/IAS/project-name/script_name.json

=item * ~/.config/IAS/project-name/project-name.json

=back

The IAS::Infra::Config.pm module is the thing that loads the configuration files.

=cut

our @UP_PATH_COMPONENTS;
our @POST_PATH_COMPONENTS;

my $SCRIPT_ABS_PATH;
my @SCRIPT_PATH_PARTS;
our $PROJECT_NAME;

our $SCRIPT_WITHOUT_EXTENSION = $Script;
$SCRIPT_WITHOUT_EXTENSION =~ s/(\.[^.]+)$//;

our $real_script_full_path = join('/', $RealBin, $RealScript);
our $real_script_uid = (stat $real_script_full_path)[4];

my $previous_pass_through;

{
	local $Getopt::Long::passthrough=1;

	GetOptions(
		$OPTIONS,
		'log-dir=s',
		'output-dir=s',
		'input-dir=s',
		'template-dir=s',

		'json-script-config-name=s',
		'json-project-config-name=s',

		'bin-dir=s',
		'conf-dir=s',
		'root-conf-dir=s',
		'home-conf-dir=s',
	
		'chosen-bin=s',
	);

}

our %FILE_FIND_BIN = (
	'RealBin' => $RealBin,
	'Bin' => $Bin,
);

our $DEFAULT_CHOSEN_BIN = 'RealBin';

# If we're being run through a symbolic link
if (-l $0)
{
	my $dollar_0_l_uid = (lstat $0)[4];
	# If onwer of $0 is the user running the process
	if ($dollar_0_l_uid == $<)
	{
		# But, the REAL script file is not owned by the current user
		if ($real_script_uid != $<)
		{
			# Then we assume that we want the paths to be relative to 
			# $0 ; otherwise they would have just run it directly.
			$DEFAULT_CHOSEN_BIN = 'Bin';
		}
	}
}

# And then we let them override the decision with
# --chosen-bin
$OPTIONS->{'chosen-bin'} ||= $DEFAULT_CHOSEN_BIN;

our $CHOSEN_BIN = $OPTIONS->{'bin-dir'}
	|| $FILE_FIND_BIN{$OPTIONS->{'chosen-bin'}};

if (!$CHOSEN_BIN)
{
	my @msg = ();
	push @msg, "*****************************************************************";
	push @msg, "You specified an unknown directory to use as my bin directory.";
	push @msg, "By default I'll use RealBin, unless you are running this script";
	push @msg, "through a symbolic link, AND you don't own the file the symbolic";
	push @msg, "link points to, in which case I will use Bin.";
	push @msg, "You can override my attempts at being smart by specifying";
	push @msg, "--chosen-bin with: ".join(', ', keys %FILE_FIND_BIN);
	push @msg, "These correspond to \$RealBin and \$Bin in the FindBin module.";
	push @msg, "*****************************************************************";
	die (join("\n", @msg)."\n");
}

$SCRIPT_ABS_PATH = File::Spec->rel2abs($CHOSEN_BIN);
@SCRIPT_PATH_PARTS = split('/',$SCRIPT_ABS_PATH);
$PROJECT_NAME = $SCRIPT_PATH_PARTS[-1];

# Use something like this if you want each script in this project
# to have its own configuration directory
# @POST_PATH_COMPONENTS = ($PROJECT_NAME, $SCRIPT_WITHOUT_EXTENSION);

# Or, just all of the configs in one directory:
@POST_PATH_COMPONENTS = ($PROJECT_NAME);

@UP_PATH_COMPONENTS = (
	$CHOSEN_BIN,
	'..',
	'..',
);


	# Test if we're in a "src" environment; chances are we're not installed
	# with a package.


if($SCRIPT_PATH_PARTS[-2] eq 'src')
{
	$OPTIONS->{'auto-dev-mode'} = 1;

	$PROJECT_NAME = $SCRIPT_PATH_PARTS[-3];
	@UP_PATH_COMPONENTS=($CHOSEN_BIN,'..');
	$PROJECT_NAME = $SCRIPT_PATH_PARTS[-3];
	
	$PROJECT_NAME =~ s/_/-/g;
	# If you want all scripts to output to output/project-name
	@POST_PATH_COMPONENTS = ();
		
	# Uncomment this if you want each script to have its own
	# output directory
		
	# @POST_PATH_COMPONENTS=($SCRIPT_WITHOUT_EXTENSION);

}

if ($OPTIONS->{'auto-dev-mode'})
{
	$OPTIONS->{'root-conf-dir'} ||= $SCRIPT_ABS_PATH."/../root_etc/IAS/$PROJECT_NAME";
}
else
{
	$OPTIONS->{'root-conf-dir'} ||= "/etc/IAS/$PROJECT_NAME";
}

use File::HomeDir;

$OPTIONS->{'home-conf-dir'} ||= File::HomeDir->my_home."/.config/IAS/$PROJECT_NAME";


sub debug_paths
{
	my ($self) = @_;
	
	$self->log_debug('Project name: ', $self->project_name());
	$self->log_debug('Script without extension:', $self->script_without_extension());
	$self->log_debug('Log dir: ', $self->log_dir());
	$self->log_debug('Output dir: ', $self->output_dir());
	$self->log_debug('Input dir: ', $self->input_dir());
	$self->log_debug('Template dir: ', $self->template_dir());

	$self->log_debug('Home Conf dir: ', $self->home_conf_dir());
	$self->log_debug('Root conf dir: ', $self->root_conf_dir());
	$self->log_debug('Conf dir: ', $self->conf_dir());


	$self->log_debug('Root /etc/ JSON config name: ', $self->root_json_config_file_name());
	$self->log_debug('Root /etc/ JSON project config name: ', $self->root_json_project_config_file_name());
	
	$self->log_debug('Home JSON config name: ', $self->home_json_config_file_name());
	$self->log_debug('Home JSON project config name: ', $self->home_json_project_config_file_name());
	
	$self->log_debug('JSON config name: ', $self->json_config_file_name());
	$self->log_debug('JSON project config name: ', $self->json_project_config_file_name());

	
	$self->log_debug('Generic file name: ', $self->get_generic_output_file_name());
	$self->log_debug('Generic file name path: ', $self->get_generic_output_file_path());
	
	$self->log_debug('Chosen Bin: ', $OPTIONS->{'chosen-bin'});
	$self->log_debug('Default FindBin Chosen Bin: ', $DEFAULT_CHOSEN_BIN);
	$self->log_debug('Bin dir: ', $self->bin_dir());
}

sub project_name
{
	return $PROJECT_NAME;
}

sub script_without_extension
{
	return $SCRIPT_WITHOUT_EXTENSION;
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

sub bin_dir
{
	my ($self) = @_;
	
	return $OPTIONS->{'bin-dir'}
		|| $CHOSEN_BIN;
}

sub template_dir
{
	my ($self) = @_;
	return $OPTIONS->{'template-dir'}
		|| join('/', @UP_PATH_COMPONENTS, 'templates',@POST_PATH_COMPONENTS);
}


sub log_dir
{
	my ($self) = @_;
	return $OPTIONS->{'log-dir'}
		|| join('/', @UP_PATH_COMPONENTS, 'log',@POST_PATH_COMPONENTS);
}

sub output_dir
{
	my ($self) = @_;
	return $OPTIONS->{'output-dir'}
		|| join('/', @UP_PATH_COMPONENTS, 'output',@POST_PATH_COMPONENTS);
}

sub input_dir
{
	my ($self) = @_;
	return $OPTIONS->{'input-dir'}
		|| join('/', @UP_PATH_COMPONENTS, 'input',@POST_PATH_COMPONENTS);
}

sub get_generic_output_file_name
{
	my ($self, $options) = @_;
	
	my $label=$options->{label}
		|| $self->script_without_extension() ;
		
	my $extension=$options->{extension}
		|| 'txt';
	
	my $file_name = join('--',
		$SCRIPT_WITHOUT_EXTENSION,
		$label,
		get_yyyy_mm_dd_hh_mm_ss(),
	).'.'.$extension;
	
	return $file_name;
	
}

sub get_generic_output_file_path
{
	my ($self, $options) = @_;
	
	my $file_name = $self->get_generic_output_file_name($options);
	
	return join('/',
		$self->output_dir(),
		$file_name,
	);
}

sub get_yyyy_mm_dd_hh_mm_ss
{
	use POSIX qw(strftime);
	return strftime("%Y-%m-%d-%H-%M-%S", localtime);
}

sub home_conf_dir
{
	my ($self) = @_;
	return $OPTIONS->{'home-conf-dir'};
}

sub root_conf_dir
{
	my ($self) = @_;
	return $OPTIONS->{'root-conf-dir'};
}

sub conf_dir
{
	my ($self) = @_;
	return $OPTIONS->{'conf-dir'}
		|| join('/', @UP_PATH_COMPONENTS, 'etc',@POST_PATH_COMPONENTS);
}

sub home_json_project_config_file_name
{
	my ($self) = @_;
	my $json_file = $self->project_name().'.json';
	return join('/', $self->home_conf_dir(), $json_file);
}


sub root_json_project_config_file_name
{
	my ($self) = @_;
	my $json_file = $self->project_name().'.json';
	return join('/', $self->root_conf_dir(), $json_file);
}

sub json_project_config_file_name
{
	# This is sloppy
	my ($self) = @_;
	
	my $json_file = $self->project_name().'.json';

	return $OPTIONS->{'json-project-config-name'}
		|| join('/', $self->conf_dir(),$json_file);

}

sub home_json_config_file_name
{
	my ($self) = @_;
	my $json_file = $SCRIPT_WITHOUT_EXTENSION.'.json';
	return join('/', $self->home_conf_dir(), $json_file);
}

sub root_json_config_file_name
{
	my ($self) = @_;
	my $json_file = $SCRIPT_WITHOUT_EXTENSION.'.json';
	return join('/', $self->root_conf_dir(), $json_file);
}

sub json_config_file_name
{
	# This is sloppy
	my ($self) = @_;
	
	my $json_file = $SCRIPT_WITHOUT_EXTENSION.'.json';

	return $OPTIONS->{'json-script-config-name'}
		|| join('/', $self->conf_dir(),$json_file);
}

sub get_all_config_paths
{
	my ($self) = @_;

	

	my @list = (
		$self->json_project_config_file_name(),
		$self->json_config_file_name(),

		$self->root_json_project_config_file_name(),
		$self->root_json_config_file_name(),
		
		$self->home_json_project_config_file_name(),
		$self->home_json_config_file_name(),

	);
	
	my %hash;
	foreach my $element (@list)
	{
		$hash{$element}++;
	}

	my $ar = [ keys %hash ];
	
	# print "****************************************\n";
	# print "****************************************\n";
	# print Dumper($ar);
	# print "****************************************\n";
	# print "****************************************\n";
	return $ar;
}

1;


