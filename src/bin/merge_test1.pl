#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

use Hash::Merge::Simple;

use JSON;

our %ALLOWED_MAPS = (
	'IAS::test1' => \%IAS::test1::OPTIONS,
	'IAS::test2' => \%IAS::test2::OPTIONS,
);

# IAS::test1::dump_options();
# IAS::test2::dump_options();

my $manip = 'IAS::test1::get_option_target';
my $b = 'IAS::test1::OPTIONS';

no strict 'refs';

# my $ptr=\${$manip};

my $ptr = \&{$manip};

# my $ptr = \&{"IAS\::test1\::get_option_target"};

# my $ptr = ${'IAS\::test1'}::get_option_target();


print Dumper($ptr->());

# print Dumper($ptr);

exit;

BEGIN {
package IAS::test1;
use Data::Dumper;

our $OPTIONS = {
	name => "test1 options",
};

our $TARGET_OPTIONS = {
	name => "Target options",
};

sub get_option_target
{
	return \$TARGET_OPTIONS;
}

sub dump_options
{
	my $msg = sprintf("%s",
		__PACKAGE__ . " options:\n" . Dumper($OPTIONS)
	);

	print $msg;

}

package IAS::test2;
use Data::Dumper;

our $OPTIONS = {};

sub dump_options
{
	my $msg = sprintf("%s",
		__PACKAGE__ . " options:\n" . Dumper($OPTIONS)
	);

	print $msg;

}

}
