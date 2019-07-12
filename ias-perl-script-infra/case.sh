#!/bin/bash

# This file contains mappings to what could be considered "common"
# entries between package systems.  While entries in here are
# sometimes package system specific, they're potentially "generic"
# and "simple" enough to justify inclusion here.
#
# This is mostly necessary to have only one source for the following
# information:
#    * package version
#    * RPM Summary / Debian Requires "Synopsis"
#    * RPM Description / Debian Multi-line description
#
# If you do not want any entry to automatically be included in your
# package definition then remove the line in the appropriate _package_fields
# array.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

description_file="$script_dir/common/description"
synopsis_file="$script_dir/common/synopsis"

changelog_file="$script_dir/changelog"

artifact_name=$(echo "$script_dir"| awk -F'/' '{print $NF}')
release_version=$( cat "${changelog_file}" | grep -v '^\s+$' | head -n 1 | awk '{print $2}')
arch=$( cat "${changelog_file}" | grep -v '^\s+$' | head -n 1 | awk '{print $3}'|sed 's/;//')
src_version=$( echo "$release_version" | awk -F '-' '{print $1}')
pkg_version=$( echo "$release_version" | awk -F '-' '{print $2}')

DEB_package_fields=( \
	"Architecture" \
	"Priority" \
	"Maintainer" \
	"Package" \
	"Version" \
	"Description" \
)

RPM_package_fields=( \
	"AutoReqProv" \
	"Group" \
	"License" \
	"Vendor" \
	"BuildArch" \
	"Summary" \
	"Name" \
	"Version" \
	"Release" \
	"Packager" \
)

function package_field_mapping
{
	local entry="$1"

	case $entry in
	# Generic Entries
		"DEB_Description_synopsis"|"RPM_Summary")
			cat "$synopsis_file"
			;;
		'DEB_Package'|'RPM_Name')
			echo "$artifact_name"
			;;
	# RPM -- Basic
		"RPM_Requires")
			# Whitespace separated list of RPM dependencies
			echo ''
			;;
		'RPM_Version')
			echo "$src_version"
			;;
		'RPM_Release')
			echo "$pkg_version"
			;;
		"RPM_AutoReqProv")
			echo 'no'
			;;
		"RPM_Group")
			echo 'Generic Group'
			;;
		"RPM_License")
			echo 'Generic License'
			;;
		"RPM_Vendor")
			echo 'Generic Vendor'
			;;
		"RPM_BuildArch")
			echo "noarch"
			;;
		"RPM_Packager")
			echo "$LOGNAME"
			;;
	# Debian -- Basic
		'DEB_Architecture')
			echo "all"
			;;
		'DEB_Priority')
			echo 'optional'
			;;
		'DEB_Maintainer')
			echo "GenericMaintainer"
			;;
		'DEB_Description')
			package_field_mapping "DEB_Description_synopsis"
			cat "$description_file"	\
				| egrep -v '^\s*$$' \
				| sed 's/^/ /' 
			;;
		'DEB_Version')
			echo "$release_version"
			;;
	# Default
		*) echo "Dunno: $entry"
			;;
	esac
}

function get_package_entry
{
	local package_system="$1"
	local entry="$2"
	
	case $package_system in
		"DEB")
			get_package_entry_DEB "$entry"
			;;
		"RPM")
			get_package_entry_RPM "$entry"
			;;
		*)
			echo "Bad package system type."
			exit 1
			;;
	esac
}

function get_package_entry_DEB
{
	local entry="$1"
	echo "$entry:" "$( package_field_mapping "DEB_${entry}")"
}

function get_package_entry_RPM
{
	local entry="$1"
	echo "$entry:" "$( package_field_mapping "RPM_${entry}")"
}

function list_all_entries
{
	local package_system="$1"
	# echo "ALl entries for: $package_system"

	case $package_system in
		"DEB")
			list_all_entries_DEB
			;;
		"RPM")
			list_all_entries_RPM
	esac
}

function list_all_entries_DEB
{

	for i in "${DEB_package_fields[@]}"
	do
		get_package_entry_DEB "$i"
	done
}

function list_all_entries_RPM
{

	for i in "${RPM_package_fields[@]}"
	do
		get_package_entry_RPM "$i"
	done
}

mode="$1"
shift

case $mode in
	"single")
		get_package_entry "$1" "$2"
		;;
	"all")
		list_all_entries "$1"
		;;
	*)
		echo "Bad mode."
		exit 1;
		;;
esac

