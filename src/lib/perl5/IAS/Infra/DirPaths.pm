package IAS::Infra::DirPaths;

use strict;
use warnings;

=pod

=head1 NAME

IAS::Infra::DirPaths

=head1 SYNOPSIS

  none yet, experimental

=head1 DESCRIPTION

Given the "right" config, should return the path to files
inside an Infra layout

A reason for it being considered experimental is that when referring to
Library files, it will refer to the library relative to the current
path of this file.

Using something like:
  {
  	local $IAS::Infra::DirPaths::LIB_DIR= ...
  }
*might* be okay for finding things relative to another library path
but I haven't tested it.

=cut


use base 'IAS::Infra';
use Data::Dumper;

our $LIB_DIR = dirname(__FILE__).'/'. ('../' x (scalar (split('::',__PACKAGE__)) -1));
our $LIB_LANG = "perl5";

sub lib_dir
{
	my ($self) = @_;

	return $LIB_DIR;
}

sub get_infra_dir_path
{
	my ($self, $data) = @_;
	my $path;
	
	my $wanted_dir = $data->{dir};

	if ($data->{dir} eq 'path')
	{
		return $data->{'name'};
	}
	
	if ($data->{dir} eq 'lib')
	{
		my $lang = $LIB_LANG;
		
		if (defined $data->{options}
			&& defined $data->{options}->{'lib_lang'}
		)
		{
			$lang = $data->{options}->{'lib_lang'};
			$path = $self->lib_dir().'../'.$lang;
		}
		else
		{
			$path = $self->lib_dir();
		}
	}
	else
	{
		my $func = $wanted_dir.'_dir';
		$path = $self->$func();
	}
	
	# print "Infra dir path for ".$data->{dir}." : ", $path,$/;
	return join('/', $path, $data->{'name'});
}

1;


