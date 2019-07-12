package IAS::Infra::CGIBinPaths;

use strict;
use warnings;

use Cwd;
use File::Basename;

sub new
{
	my ($type, $self) = shift;
	$self ||= {};

	my ($package, $filename, $line) = caller;
	return bless $self, $type;
}

sub conf_dir
{
	my ($self) = @_;
	
	return File::Basename::dirname($self->{RealPath})."/../etc";
}


1;
