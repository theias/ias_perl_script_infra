package IAS::Infra::Config;

=pod

=head1 NAME

IAS::Infra::Config

=head1 SYNOPSIS

  # Config options (all optional)

  # Automatically search for configuration files and load them
  # Defaults to 1
  --auto-config 

  # Manually specify a list of json files to include; completely overrides default list:
  --json-config-paths=/path/to/file.json [ --json-config-paths=/path/to/another/file.json ] ...
  
  # Dump what paths are being used to find configuration files and exit:
  --dump-config-paths

=head1 DESCRIPTION

Automatically loads and processes json configuration files.

Files can look like this:

  {
      "IAS::Infra::Logger": {
          "log-devel": 1,
          "log-debug-names": [
              "debug-name-1",
              "debug-name-2"
          ]
       },

     "IAS::ProgramName":{
         "config-option-two": "config option 2 set in json",
         "config-option-three": "config option 3 set in json"
     }
 }

Foreach Perl package listed, it will then call the subroutine "apply_options_precedence"
(if it's defined in that package) , with the data structure under the package name.

So:

  IAS::ProgramName::apply_options_precedence(
       "config-option-two" => "config option 2 set in json",
       "config-option-three" => "config option 3 set in json"
     }
  )

The typical behavior of apply_options_precedence() is to merge the data with
the "our $OPTIONS={}" variable, which also will get merged with command line
options.

This allows for the following configruation file precedence:

=over 4

=item Command line options

=item Configuration files

=item Module defaults

=back

where command line options have the highest precedence and module defaults
have the lowest.

The module will log what configuration files it has loaded.

If you do not have apply_options_precedence() defined in your module
you can still access the built configuration structure through:

  $self->{'built_config'};

=cut

use strict;
use warnings;

use Hash::Merge::Simple;
use JSON;
use Getopt::Long;
use Data::Dumper;


our $OPTIONS={};

{
	local $Getopt::Long::passthrough=1;

	GetOptions(
		$OPTIONS,
		'auto-config!',
		'json-config-paths=s@',
		'dump-config-paths!',
	);
}

sub get_default_options_ref
{
	return \$OPTIONS;
}

sub load_config
{
	my ($self) = @_;
	
	$self->log_debug("Running load config routine...");
	
	$self->do_automatic_config();
}

sub do_automatic_config
{
	my ($self) = @_;

	return if (
		defined $OPTIONS->{'auto-config'}
		&& ! $OPTIONS->{'auto-config'}
	);

	$OPTIONS->{'json-config-paths'} ||= $self->get_all_config_paths();
	
	my $config_files = $OPTIONS->{'json-config-paths'};

	
	if ($OPTIONS->{'dump-config-paths'})
	{
		print 'dump-config-paths',$/;
		print "Configuration search paths in order:\n";
		print Dumper($config_files);
		exit;
	}
	
	my $built_config = {};

	CONFIG_FILE: foreach my $config_file (@$config_files)
	{
		next if ! -e $config_file;
		
		my $content = $self->load_file_content($config_file);
		
		if (! $content)
		{
			$self->log_debug("Loaded json config file was empty: $config_file");
			next CONFIG_FILE;
		}
		
		my $config = decode_json($content);
		
		

		$built_config = Hash::Merge::Simple::merge(
			$built_config,
			$config,
		);
		
		$self->log_info("Loaded configuration file: ", $config_file);
	}

	$self->{built_config} = $built_config;

	$self->process_config($self->{built_config});
}

sub load_file_content
{
	my ($self,$file_name) = @_;

	use IO::File;

	my $fh = new IO::File "<$file_name";
	if (! $fh)
	{
		$self->log_critic("Could not open $file_name for reading: $!");
		exit 1;
	}
	
	my $content;
	
	{
		local $/;
		$content = <$fh>;
	}
	
	$fh->close();
	
	return $content;
}

sub process_config
{
	my ($self, $data) = @_;
	
	my $package_name;

	no strict 'refs';
		
	foreach $package_name (keys %$data)
	{
		my $target = "$package_name".'::apply_options_precedence';

		my $ptr = \&{$target};
		
		if (! defined(&$ptr))
		{
			next;
		}
		else
		{
			$ptr->($data->{$package_name});
		}
	}

	use strict 'refs';

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

1;
