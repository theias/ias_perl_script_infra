#!/bin/bash

# Bootstrap testing infrastructure
IAS_test_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. "$my_lib_dir/bash5/IAS/Tests/TestProjectPaths.bash"
. "$test_vendor_lib_dir/bash5/IAS/Tests/SimpleLibrary.bash"
