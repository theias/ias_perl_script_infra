#!/bin/bash

# This hasn't been worked out fully yet
# But this is how you'd test if symbolic linking
# works "correctly"
cp config_app_test.pl root_config_app_test.pl

mkdir link_test

cd link_test || exit 1

ln -s ../root_config_app_test.pl ./root_config_app_test.pl

chown "$1" ./root_config_app_test.pl

su "$1" -c './root_config_app_test.pl --log-devel'

cd ../ || exit 1

rm -rf link_test
rm -f root_config_app_test.pl
