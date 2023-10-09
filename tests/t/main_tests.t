#!/bin/bash
# vim: set filetype=sh :
set -e

# Bootstrap testing infrastructure
this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
my_lib_dir=${my_lib_dir:-"$this_dir/../lib"}
. "$my_lib_dir/bash5/IAS/Tests/Bootstrap.bash"
. "$test_etc_dir/test_config.bash"
# End bootstrap

# This is an example from the test-simple.bash
# git repo
# . "$test_lib_dir/test-simple.bash" tests 5
#
# ok 0 '0 is true (other numbers are false.)'
# answer="yes"
# ok [ $answer == yes ]   'The answer is yes!'
# ok [[ $answer =~ ^y ]]  'The answer begins with y'
#
# ok true 'true is ok'
# ok '! false' '! false is true'

. "$test_simple_bash" tests 2

ok "$test_bin_dir/test_an_ias_application.sh" 'A test should run.'
ok "$test_bin_dir/test_config_app_test.sh" 'configuration tests should pass'

