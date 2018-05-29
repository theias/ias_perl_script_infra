ARTIFACT_NAME = ias-perl-script-infra

MAKEFILE_PATH = $(strip $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

include $(MAKEFILE_PATH)/package_shell/make/project-base_variables.gmk

include $(MAKEFILE_PATH)/package_shell/make/make-standard_phonies.gmk

include $(MAKEFILE_PATH)/package_shell/make/project_directories-full_project.gmk
include $(MAKEFILE_PATH)/package_shell/make/make-debug.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_shell-additional.gmk
include $(MAKEFILE_PATH)/package_shell/make/source-basic_tests.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_install-base_directories.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_install-conditional_additions.gmk

include $(MAKEFILE_PATH)/package_shell/make/package_build-rpm.gmk
include $(MAKEFILE_PATH)/package_shell/make/package_build-deb.gmk


