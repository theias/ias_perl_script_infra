package IAS::Infra::CGIBinPaths;

use strict;
use warnings;

use Cwd;
use File::Basename;
use Data::Dumper;

sub new
{
	my ($type, $self) = shift;
	$self ||= {};

	my ($package, $filename, $line) = caller;

	$self->{whence} ||= "RealBin";
		
	$self->{caller_filename} = $filename;

	$self->{RealScript} = Cwd::realpath($filename);
	$self->{Script} = basename($filename);
	
	$self->{Bin} = dirname($filename);
	$self->{RealBin} = dirname($self->{RealScript});

	bless $self, $type;
	
	$self->is_in_src_dir();
	return $self;
}

sub is_in_src_dir
{
	my ($self) = @_;
	if (! defined $self->{in_src_dir})
	{
		my $whence = $self->{$self->{whence}};
		
		$whence =~ s/\/\//\//g;
		
		my @path_parts = split('/',$whence);
		# print Dumper(\@path_parts);
		if ($path_parts[-2] eq 'src')
		{
			return $self->{in_src_dir} = 1;
		}
		return $self->{in_src_dir} = 0;
	}
	return $self->{in_src_dir};
}

sub conf_dir
{
	my ($self) = @_;
	
	return File::Basename::dirname($self->{RealPath})."/../etc";
}


1;
