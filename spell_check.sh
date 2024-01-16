#!/bin/bash

# This can serve as an example for how to spell check source
# files, and save your word additions to "aspell_project.pws"
# so the preference file stays with your project.

bin_whence="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ASPELL_PROJECT_FILE=${ASPELL_PROJECT_FILE:-"$bin_whence/aspell_project.pws"}

find "$bin_whence" -not -path "./build/*" -type f \
| grep -E -i '(.md)$' \
| xargs -n1 -i sh -c "aspell --dont-backup --mode=sgml -p \"$ASPELL_PROJECT_FILE\" -c \"{}\" < /dev/tty"

find "$bin_whence" -not -path "./build/*" -type f \
| grep -E -vi '(.md)$' \
| grep -E '.(tex|txt|text)$' \
| grep -Ev '.(egg-info)' \
| xargs -n1 -i sh -c "aspell --dont-backup -p \"$ASPELL_PROJECT_FILE\" -c \"{}\" < /dev/tty"

