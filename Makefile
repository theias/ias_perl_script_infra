###########################
# Advanced Usage below.
###########################

MAKEFILE_PATH = $(strip $(dir $(firstword $(MAKEFILE_LIST))))
PACKAGE_SHELL_INCLUDE_PATH=$(MAKEFILE_PATH)/package_shell/make

include $(MAKEFILE_PATH)/base.gmk

# The following are optional in base.gmk ,
# but must be set before the other stuff loads
ifeq ($(BASE_DIR),)
	BASE_DIR := /opt/IAS
endif


include $(PACKAGE_SHELL_INCLUDE_PATH)/project-base_variables.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/make-standard_phonies.gmk

ifneq ("$(wildcard $(ARTIFACT_DIR)/artifact_variables.gmk)","")
	include $(ARTIFACT_DIR)/artifact_variables.gmk
endif

ifeq ($(PROJECT_DIRECTORIES_MAKE_FILE),)
	PROJECT_DIRECTORIES_MAKE_FILE:=project_directories-full_project.gmk
endif
ifeq ($(PROJECT_DIRECTORIES_ARE_DEFINED),)
	include $(PACKAGE_SHELL_INCLUDE_PATH)/$(PROJECT_DIRECTORIES_MAKE_FILE)
	
endif

include $(PACKAGE_SHELL_INCLUDE_PATH)/package_shell-additional.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/source-basic_tests.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-base_directories.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-conditional_additions.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-code_repository_info.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-final_cleanup.gmk

include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-mapped_symbolic_links.gmk

# Supported package systems
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_build-rpm.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_build-deb.gmk

.PHONY: debug-ALL

debug-ALL: \
	debug-base-Makefile \
	debug-project-base_variables \
	debug-make-standard_phonies \
	debug-project_directories \
	debug-package_shell-additional \
	debug-source-basic_tests \
	debug-package_install-base_directories \
	debug-package_install-conditional_additions \
	debug-package_install-final_cleanup \
	debug-package_build-rpm \
	debug-package_build-deb \
	debug-package_install-mapped_symbolic_links \
	debug-package_install-code_repository_info

.PHONY: debug-base-Makefile

debug-base-Makefile:
	# Makefile - debug variables
	#   ARTIFACT_NAME: '$(ARTIFACT_NAME)'
	#   MAKEFILE_PATH: '$(MAKEFILE_PATH)'
	#   PACKAGE_SHELL_INCLUDE_PATH: '$(PACKAGE_SHELL_INCLUDE_PATH)'
	#
