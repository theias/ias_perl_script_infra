ARTIFACT_NAME = ias-perl-script-infra

BASE_DIR = /opt/IAS

SHELL_PWD = $(shell echo `pwd`)
MAKEFILE_PATH = $(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

PROJECT_DIR = $(MAKEFILE_PATH)
SCRATCH_AREA = $(SHELL_PWD)

# PROJECT_DIR = $(SHELL_PWD)

CHANGELOG_FILE = $(PROJECT_DIR)/$(ARTIFACT_NAME)/changelog

RELEASE_VERSION := $(shell cat '$(CHANGELOG_FILE)' | grep -v '^\s+$$' | head -n 1 | awk '{print $$2}')
ARCH := $(shell cat $(CHANGELOG_FILE) | grep -v '^\s+$$' | head -n 1 | awk '{print $$3}'|sed 's/;//')
SRC_VERSION := $(shell echo '$(RELEASE_VERSION)' | awk -F '-' '{print $$1}')
PKG_VERSION := $(shell echo '$(RELEASE_VERSION)' | awk -F '-' '{print $$2}')

SRC_DIR = $(PROJECT_DIR)/src

DROP_DIR = $(SCRATCH_AREA)/drop
BUILD_DIR = $(SCRATCH_AREA)/build
SPEC_FILE_NAME = $(ARTIFACT_NAME)-$(RELEASE_VERSION)--pkginfo.spec
SPEC_FILE = $(BUILD_DIR)/$(SPEC_FILE_NAME)
ROOT_DIR = $(BUILD_DIR)/root

INST_DIR = $(BASE_DIR)/$(ARTIFACT_NAME)

BIN_DIR=$(BASE_DIR)/bin/$(ARTIFACT_NAME)
BIN_INST_DIR=$(ROOT_DIR)/$(BIN_DIR)

CGI_BIN_DIR=$(BASE_DIR)/cgi-bin/$(ARTIFACT_NAME)
CGI_BIN_INST_DIR=$(ROOT_DIR)/$(CGI_BIN_DIR)

LIB_DIR=$(BASE_DIR)/lib
LIB_INST_DIR=$(ROOT_DIR)/$(LIB_DIR)

DOC_BASE_DIR=$(BASE_DIR)/doc
DOC_DIR=$(DOC_BASE_DIR)/$(ARTIFACT_NAME)
DOC_INST_DIR=$(ROOT_DIR)$(DOC_DIR)

TEMPLATE_DIR=$(BASE_DIR)/templates/$(ARTIFACT_NAME)
TEMPLATE_INST_DIR=$(ROOT_DIR)/$(TEMPLATE_DIR)

# Directories for FullProjectPath type apps:
INPUT_BASE_DIR=$(BASE_DIR)/input
OUTPUT_BASE_DIR=$(BASE_DIR)/output
CONF_BASE_DIR=$(BASE_DIR)/etc
LOG_BASE_DIR=$(BASE_DIR)/log


INPUT_DIR=$(INPUT_BASE_DIR)/$(ARTIFACT_NAME)
OUTPUT_DIR=$(OUTPUT_BASE_DIR)/$(ARTIFACT_NAME)
CONF_DIR=$(CONF_BASE_DIR)/$(ARTIFACT_NAME)
LOG_DIR=$(LOG_BASE_DIR)/$(ARTIFACT_NAME)


DEB_DIR=$(ROOT_DIR)/DEBIAN
DEB_CONTROL_FILE=$(DEB_DIR)/control
DEB_CONF_FILES_FILE=$(DEB_DIR)/conffiles

SUMMARY := $(shell egrep '^Summary:' ./$(ARTIFACT_NAME)/rpm_specific | awk -F ':' '{print $$2}')

include $(MAKEFILE_PATH)/package_shell/make/make-debug.gmk

all:

clean:
	-rm -rf $(PROJECT_DIR)/build



package-rpm: clean all install rpmspec rpmbuild

package-deb: clean all install debsetup debbuild

release: test-all



builddir:
	if [ ! -d build ]; then mkdir build; fi;

self-replicate: install
	# Self Replicating
	# This will put a copy of the source tree in a tar.gz file
	# in the doc dir.
	
	ls | egrep -v '(build|\.svn)' | \
		xargs -n1 -i cp -r {} ./build/$(ARTIFACT_NAME)-$(RELEASE_VERSION)/
	
	cd build && tar czvf $(ARTIFACT_NAME)-$(RELEASE_VERSION).tar.gz \
		$(ARTIFACT_NAME)-$(RELEASE_VERSION)
	
	mv build/$(ARTIFACT_NAME)-$(RELEASE_VERSION).tar.gz $(DOC_INST_DIR)/

include $(MAKEFILE_PATH)/package_shell/make/source-basic_tests.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_install-base_directories.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_install-conditional_additions.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_build-rpm.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_build-deb.gmk


	

