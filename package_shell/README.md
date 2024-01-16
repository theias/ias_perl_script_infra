# Design Goals

The files in this directory have been designed to not need to be changed on
a per-project or a per-artifact basis.

For changing behavior of the artifact rules, use artifact-name/artifact_variables.gmk .

Ideally, this will allow for subsequent release for package shell to update the code
and (hopefully) allow for the maintainer to put the code in place without having
to regenerate the project layout.
