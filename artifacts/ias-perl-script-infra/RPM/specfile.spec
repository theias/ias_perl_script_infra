# This file will have stuff written to the beginning of it
# when the package is built.
#
# Prevent binary stripping:
%global __os_install_post %{nil}
#
# Don't error out because of arch dependent binaries:
%define _binaries_in_noarch_packages_terminate_build   0
#
# RPM dependencies are whitespace separated
# Requires:
