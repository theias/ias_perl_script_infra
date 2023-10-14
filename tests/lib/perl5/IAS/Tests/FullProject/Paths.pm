package IAS::Tests::FullProject::Paths;

use strict;
use warnings;

use Carp;
use File::Basename;

our $PATHS = {

};

sub parse_project_paths
{
	my ($lines) = @_;
	my $current_key;

	process_line: foreach my $line (split("\n", $lines))
	{
		chomp $line;
		# Blank lines at the start with no key defined
		# get thrown away
		next process_line
			if ($line =~ m/^\s*$/ && ! defined $current_key);
		if ($line =~ m/#\s+(\S+)\s+(.*)\s*$/)
		{
			$current_key = $1;
			$PATHS->{$current_key} = $2;
		}
		else
		{
			carp "This line:\n\t$line\nDoesn't match the format we expect.";
		}
	}
}

our $bash5_lib_dir = dirname(__FILE__) . "/../../../../bash5";
our $bash5_test_project_paths = "$bash5_lib_dir/IAS/Tests/TestProjectPaths.bash";

our $bash5_test_project_paths_debug_output = 
	`. $bash5_test_project_paths ; debug_test_project_paths`;


sub new
{
	my $type = shift;
	my $self = {};
	return bless $self, $type;
}

1;
