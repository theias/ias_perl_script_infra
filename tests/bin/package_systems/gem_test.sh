#!/bin/bash

# Bootstrap testing infrastructure
this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
my_etc_dir=${my_etc_dir:-"$this_dir/../../etc"}
. "$my_etc_dir/test_project_paths.bash"


gem_example_dir=${pip_example_dir:-"$project_examples_dir/gem/"}
gem_Makefile=${pip_Makefile:-"$project_dir/gem_Makefile"}

# debug_test_script

# Copy gem code to where it needs to be
if [[ ! -e "$gem_Makefile" ]]
then
	cp --no-clobber "$gem_example_dir"/* "$project_dir"
	if [[ ! $? ]]
	then
		>&2 echo "Unable to copy $gem_example_dir to $project_dir"
		exit 1
	fi
fi

cd "$project_dir" && make -f "$gem_Makefile" gem || exit $?
