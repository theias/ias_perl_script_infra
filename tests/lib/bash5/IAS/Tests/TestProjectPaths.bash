#!/bin/bash

# This file sets up path variables that are to be used
# with tests.

this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

rp_test_dir=$( realpath "$this_dir/../../../.." )
test_dir=${test_dir:-"$rp_test_dir"}

test_etc_dir=${test_etc_dir:-"$test_dir/etc"}
test_lib_dir=${test_lib_dir:-"$test_dir/lib"}
test_vendor_lib_dir=${test_vendor_dir:-"$test_dir/vendor_lib"}
test_bin_dir=${test_bin_dir:-"$test_dir/bin"}
test_data_dir=${test_data_dir:-"$test_dir/data"}

test_t_dir=${test_t_dir:-"$test_dir/t"}

project_dir=${project_dir:-"$test_dir/../"}
project_bin_dir=${project_bin_dir:-"$project_dir/src/bin"}
project_lib_dir=${project_lib_dir:-"$project_dir/src/lib"}
project_etc_dir=${project_etc_dir:-"$project_dir/src/etc"}

project_root_etc_dir=${project_root_etc_dir:-"$project_dir/src/root_etc"}

project_input_dir=${project_input_dir:-"$project_dir/src/input"}
project_output_dir=${project_output_dir:-"$project_dir/src/output"}

project_examples_dir=${project_examples_dir:-"$project_dir/examples"}

function debug_test_project_paths
{
cat << EOF
# this_dir_conf $this_dir_conf
# test_etc_dir $test_etc_dir
# test_dir $test_dir
# test_lib_dir $test_lib_dir
# test_vendor_lib_dir $test_vendor_lib_dir
# test_bin_dir $test_bin_dir
# test_etc_dir $test_etc_dir
# test_data_dir $test_data_dir
# test_t_dir $test_t_dir
# project_dir $project_dir
# project_bin_dir $project_bin_dir
# project_lib_dir $project_lib_dir
# project_etc_dir $project_etc_dir
# project_root_etc_dir $project_root_etc_dir
# project_input_dir $project_input_dir
# project_output_dir $project_output_dir
# project_examples_dir $project_examples_dir
EOF
}
