ARTIFACT_NAME = ias-perl-script-infra

MAKEFILE_PATH = $(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

PACKAGE_SHELL_INCLUDE_PATH=$(MAKEFILE_PATH)/package_shell/make

include $(PACKAGE_SHELL_INCLUDE_PATH)/project-base_variables.gmk

include $(PACKAGE_SHELL_INCLUDE_PATH)/make-standard_phonies.gmk

include $(PACKAGE_SHELL_INCLUDE_PATH)/project_directories-full_project.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/make-debug.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_shell-additional.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/source-basic_tests.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-base_directories.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-conditional_additions.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_install-final_cleanup.gmk

# Supported package systems
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_build-rpm.gmk
include $(PACKAGE_SHELL_INCLUDE_PATH)/package_build-deb.gmk

