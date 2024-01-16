package_shell_artifact_gmks = $(wildcard artifacts/*/package_shell.gmk)
artifact_dirs := $(patsubst %/package_shell.gmk,%,$(package_shell_artifact_gmks))

package_shell_rpms=$(patsubst %,%.rpm,$(artifact_dirs))
package_shell_debs=$(patsubst %,%.deb,$(artifact_dirs))

.PHONY: debug_main_Makefile
debug_main_Makefile::
	# package_shell_artifact_gmks: $(package_shell_artifact_gmks)
	# artifact_dirs: $(artifact_dirs)
	# package_shell_rpms: $(package_shell_rpms)
	# package_shell_debs: $(package_shell_debs)

.PHONY: package-rpm
package-rpm: clean $(package_shell_rpms)

%.rpm: %
	make -f $</package_shell.gmk package-rpm

.PHONY: package-deb
package-deb: clean $(package_shell_debs)
%.deb: %
	make -f $</package_shell.gmk package-deb

clean:
	-rm -rf build
